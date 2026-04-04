import uuid
import random
import argparse
import psycopg2
from datetime import datetime, timedelta
from cassandra.cluster import Cluster
from cassandra.query import BatchStatement

# =============================================================================
# CASSANDRA SEED SCRIPT (WITH POSTGRES LOOKUP)
# =============================================================================
# This script connects to PostgreSQL to get the real product UUIDs, then
# connects to Cassandra to populate it with mock price data.
#
# Usage:
# 1. Ensure both services are running in Kubernetes.
# 2. Port-forward BOTH services to your local machine in separate terminals:
#    kubectl port-forward --address 0.0.0.0 -n <namespace> svc/postgres 5432:5432
#    kubectl port-forward --address 0.0.0.0 -n <namespace> svc/cassandra 9042:9042
# 3. Run the script:
#    python cassandra_seed_gen.py --chost host.docker.internal --pghost host.docker.internal
# =============================================================================

def fetch_product_ids_from_postgres(pg_conn_str):
    """Connects to PostgreSQL and fetches all product IDs."""
    product_ids = []
    try:
        conn = psycopg2.connect(pg_conn_str)
        print("✅ Successfully connected to PostgreSQL.")
        cur = conn.cursor()
        cur.execute("SELECT id FROM products;")
        rows = cur.fetchall()
        # The key change is here: we still get strings from the DB
        product_ids = [row[0] for row in rows]
        cur.close()
        conn.close()
        print(f"✅ Fetched {len(product_ids)} product UUIDs from PostgreSQL.")
    except Exception as e:
        print(f"❌ ERROR: Could not connect to or fetch from PostgreSQL.")
        print(f"   Is it running and port-forwarded? Connection string: {pg_conn_str}")
        print(f"   Error details: {e}")
    return product_ids

def generate_and_insert_data(host, port, keyspace, product_id_strings):
    """Connects to Cassandra, generates mock data, and inserts it."""
    if not product_id_strings:
        print("❌ No product IDs to process. Aborting Cassandra seed.")
        return

    try:
        cluster = Cluster([host], port=port)
        session = cluster.connect()
        print(f"✅ Successfully connected to Cassandra at {host}:{port}")
    except Exception as e:
        print(f"❌ ERROR: Could not connect to Cassandra. Is it running and port-forwarded?")
        print(f"   Error details: {e}")
        return

    session.execute(f"CREATE KEYSPACE IF NOT EXISTS {keyspace} WITH replication = {{'class': 'SimpleStrategy', 'replication_factor': '1'}}")
    session.set_keyspace(keyspace)
    session.execute("""
        CREATE TABLE IF NOT EXISTS price_history (
            product_id UUID,
            store_id UUID,
            price DECIMAL,
            is_on_sale BOOLEAN,
            recorded_at TIMESTAMP,
            PRIMARY KEY (product_id, recorded_at)
        )
    """)
    print(f"✅ Ensured keyspace '{keyspace}' and table 'price_history' exist.")

    session.execute("TRUNCATE price_history;")
    print("🗑️  Cleared existing data from 'price_history'.")

    store_id = uuid.UUID("e4d60c4b-1234-5678-9012-f4d60c4b3333")
    insert_query = session.prepare("INSERT INTO price_history (product_id, store_id, price, is_on_sale, recorded_at) VALUES (?, ?, ?, ?, ?)")
    
    total_inserts = 0
    batch = BatchStatement()

    print(f"🌱 Generating and inserting data for {len(product_id_strings)} products...")

    for prod_id_str in product_id_strings:
        # --- FIX: Convert the string from Postgres into a real UUID object ---
        prod_id_uuid = uuid.UUID(prod_id_str)
        
        base_price = round(random.uniform(1.00, 25.00), 2)
        num_entries = random.randint(5, 7)

        for days_ago in range(num_entries):
            is_on_sale = random.random() < 0.3
            price = round(base_price * random.uniform(0.75, 0.90), 2) if is_on_sale else round(base_price * random.uniform(0.95, 1.05), 2)
            timestamp = datetime.now() - timedelta(days=days_ago)
            
            # Use the converted UUID object for the insert
            batch.add(insert_query, (prod_id_uuid, store_id, price, is_on_sale, timestamp))
            total_inserts += 1

            if len(batch) >= 100:
                session.execute(batch)
                batch.clear()

    if len(batch) > 0:
        session.execute(batch)

    print(f"✅ All done! Inserted {total_inserts} price records for {len(product_id_strings)} products.")
    cluster.shutdown()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate and insert mock data into Cassandra after fetching IDs from PostgreSQL.")
    
    # Cassandra args
    parser.add_argument("--chost", default="127.0.0.1", help="Cassandra host IP address.")
    parser.add_argument("--cport", type=int, default=9042, help="Cassandra connection port.")
    parser.add_argument("--keyspace", default="price_service", help="The keyspace to use.")

    # PostgreSQL args
    parser.add_argument("--pghost", default="127.0.0.1", help="PostgreSQL host IP address.")
    parser.add_argument("--pgport", type=int, default=5432, help="PostgreSQL connection port.")
    parser.add_argument("--pguser", default="grocer_admin", help="PostgreSQL username.")
    parser.add_argument("--pgpassword", default="dev_secret_123", help="PostgreSQL password.")
    parser.add_argument("--pgdatabase", default="grocersave_db", help="PostgreSQL database name.")

    args = parser.parse_args()

    # Construct PostgreSQL connection string
    pg_conn_str = f"dbname='{args.pgdatabase}' user='{args.pguser}' host='{args.pghost}' port='{args.pgport}' password='{args.pgpassword}'"

    # Run the process
    product_uuids_as_strings = fetch_product_ids_from_postgres(pg_conn_str)
    generate_and_insert_data(args.chost, args.cport, args.keyspace, product_uuids_as_strings)
