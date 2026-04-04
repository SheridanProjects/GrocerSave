--
-- PostgreSQL database dump
--

\restrict tAoww3FzEsdnAoJVVOPvtW5iM5sn95I21uzEfMKFkcKPimwXzX2jvJUZ72DDjFo

-- Dumped from database version 15.17
-- Dumped by pg_dump version 15.17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.products VALUES ('22efb39d-d906-46c8-8ba8-6c6ee584958c', 'Organic Milk', '2L of organic whole milk from a local farm.', 'https://www.themealdb.com/images/ingredients/Milk.png', 'Dairy & Eggs');
INSERT INTO public.products VALUES ('2cb952b6-fba3-4df8-beb9-dbba033019ec', 'Free-Range Eggs', 'One dozen large brown free-range eggs.', 'https://www.themealdb.com/images/ingredients/Eggs.png', 'Dairy & Eggs');
INSERT INTO public.products VALUES ('e6607299-0ad2-4ae9-9778-8e3550709cbe', 'Sourdough Bread', 'Freshly baked artisan sourdough loaf.', 'https://www.themealdb.com/images/ingredients/Bread.png', 'Bakery');
INSERT INTO public.products VALUES ('43764048-47c7-4b15-b220-4d77e02ff13d', 'Avocados', 'Bag of 5 ripe Hass avocados.', 'https://www.themealdb.com/images/ingredients/Avocado.png', 'Produce');
INSERT INTO public.products VALUES ('169d6cd8-92e2-45d3-a465-f601ddfdfdc4', 'Chicken Breast', '1kg of skinless, boneless chicken breast.', 'https://www.themealdb.com/images/ingredients/Chicken.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('db3f70d2-468b-415b-a4f0-34446a9a43e6', 'Salmon Fillet', '500g of fresh Atlantic salmon fillet.', 'https://www.themealdb.com/images/ingredients/Salmon.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('fb1800e5-684d-4849-9378-fa0f2ed4c338', 'Organic Apples', 'Bag of 6 organic Gala apples.', 'https://www.themealdb.com/images/ingredients/Apples.png', 'Produce');
INSERT INTO public.products VALUES ('971329c0-b1e4-4719-82e3-79680e4797de', 'Greek Yogurt', '500g tub of plain Greek yogurt.', 'https://www.themealdb.com/images/ingredients/Yogurt.png', 'Dairy & Eggs');
INSERT INTO public.products VALUES ('811485fc-5fea-4641-b301-369c32110ab8', 'Quinoa', '1kg bag of organic white quinoa.', 'https://www.themealdb.com/images/ingredients/Quinoa.png', 'Pantry');
INSERT INTO public.products VALUES ('5327fe66-c7bf-42f7-9fca-c73985bde8b3', 'Almond Milk', '1L carton of unsweetened almond milk.', 'https://www.themealdb.com/images/ingredients/Milk.png', 'Pantry');
INSERT INTO public.products VALUES ('1baadaf9-9310-4217-bd26-80776c1f0866', 'Organic Carrots', '1kg bag of organic carrots.', 'https://www.themealdb.com/images/ingredients/Carrots.png', 'Produce');
INSERT INTO public.products VALUES ('56697754-b660-4481-975e-a30c50944a57', 'Whole Wheat Pasta', '500g pack of whole wheat fusilli.', 'https://www.themealdb.com/images/ingredients/Pasta.png', 'Pantry');
INSERT INTO public.products VALUES ('ba538a4a-46a9-499a-a75f-9a992c953fd4', 'Cheddar Cheese', '250g block of mature cheddar cheese.', 'https://www.themealdb.com/images/ingredients/Cheese.png', 'Dairy & Eggs');
INSERT INTO public.products VALUES ('c37c97cf-5088-496c-8a17-2fcb7f0b45c6', 'Tomatoes', '500g of ripe vine tomatoes.', 'https://www.themealdb.com/images/ingredients/Tomato.png', 'Produce');
INSERT INTO public.products VALUES ('3718e620-5bed-43e3-85d3-147759b88a82', 'Ground Beef', '500g of lean ground beef.', 'https://www.themealdb.com/images/ingredients/Beef.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('4f79b973-756b-4580-a689-8916e2ddacfc', 'Bananas', 'Bunch of 5 organic bananas.', 'https://www.themealdb.com/images/ingredients/Banana.png', 'Produce');
INSERT INTO public.products VALUES ('0793be5b-90fb-40dc-985c-d8fcfa2efd8d', 'Spinach', '200g bag of fresh spinach.', 'https://www.themealdb.com/images/ingredients/Spinach.png', 'Produce');
INSERT INTO public.products VALUES ('ac99fc60-1d83-4bb8-bfdc-1b7318c8978d', 'Oats', '1kg bag of rolled oats.', 'https://www.themealdb.com/images/ingredients/Oats.png', 'Pantry');
INSERT INTO public.products VALUES ('8ed84f20-9d7b-4a1b-981d-04960e29c06a', 'Blueberries', '150g punnet of fresh blueberries.', 'https://www.themealdb.com/images/ingredients/Blueberries.png', 'Produce');
INSERT INTO public.products VALUES ('d985b44b-4038-4c92-801d-143d4c095484', 'Canned Tuna', 'Can of tuna chunks in spring water.', 'https://www.themealdb.com/images/ingredients/Tuna.png', 'Pantry');
INSERT INTO public.products VALUES ('427f7430-46ea-4735-882f-be6a0cd59d49', 'Potatoes', '2kg bag of white potatoes.', 'https://www.themealdb.com/images/ingredients/Potatoes.png', 'Produce');
INSERT INTO public.products VALUES ('2ae98b82-d307-4c31-b231-c20aef8d1f10', 'Onions', '1kg bag of brown onions.', 'https://www.themealdb.com/images/ingredients/Onion.png', 'Produce');
INSERT INTO public.products VALUES ('e02e62df-9f2e-4571-93e1-ad6bae674989', 'Garlic', '3 bulbs of fresh garlic.', 'https://www.themealdb.com/images/ingredients/Garlic.png', 'Produce');
INSERT INTO public.products VALUES ('b3557e63-4d10-4010-961a-c492500099ed', 'Cucumber', 'Single large cucumber.', 'https://www.themealdb.com/images/ingredients/Cucumber.png', 'Produce');
INSERT INTO public.products VALUES ('242bd7ef-ef43-4c90-a9e4-7668bdd04aed', 'Bell Peppers', 'Pack of 3 mixed bell peppers.', 'https://www.themealdb.com/images/ingredients/Red%20Pepper.png', 'Produce');
INSERT INTO public.products VALUES ('5c624834-9bf0-4a7c-8ffd-58d75470e26c', 'Broccoli', 'Head of fresh broccoli.', 'https://www.themealdb.com/images/ingredients/Broccoli.png', 'Produce');
INSERT INTO public.products VALUES ('ab36aca3-dadb-460e-b66e-a5a87295bfe5', 'Lettuce', 'Head of iceberg lettuce.', 'https://www.themealdb.com/images/ingredients/Lettuce.png', 'Produce');
INSERT INTO public.products VALUES ('04bcf7a0-395c-4a0e-80e4-6de773513212', 'Mushrooms', '250g of closed cup mushrooms.', 'https://www.themealdb.com/images/ingredients/Mushrooms.png', 'Produce');
INSERT INTO public.products VALUES ('da1fb82b-1e29-4371-8f91-9c4776e72239', 'Orange Juice', '1L carton of fresh orange juice.', 'https://www.themealdb.com/images/ingredients/Orange.png', 'Beverages');
INSERT INTO public.products VALUES ('6b66585a-e367-4eaa-a5b4-e68dbb672856', 'Butter', '250g block of unsalted butter.', 'https://www.themealdb.com/images/ingredients/Butter.png', 'Dairy & Eggs');
INSERT INTO public.products VALUES ('da8a1593-65ea-4595-bf59-ec38fa228ab5', 'White Bread', 'Loaf of sliced white bread.', 'https://www.themealdb.com/images/ingredients/Bread.png', 'Bakery');
INSERT INTO public.products VALUES ('a5a525a0-51a0-41ac-b6c5-718542366b8e', 'Rice', '1kg bag of long-grain white rice.', 'https://www.themealdb.com/images/ingredients/Rice.png', 'Pantry');
INSERT INTO public.products VALUES ('725ffd67-5c81-4bd4-8fef-6f569faa882a', 'Lentils', '500g bag of green lentils.', 'https://www.themealdb.com/images/ingredients/Lentils.png', 'Pantry');
INSERT INTO public.products VALUES ('319de0dc-da81-446f-9890-aabfb7b3ac41', 'Chickpeas', 'Can of chickpeas in water.', 'https://www.themealdb.com/images/ingredients/Chickpeas.png', 'Pantry');
INSERT INTO public.products VALUES ('c1536af6-c587-44cd-8d70-111d42b41ee5', 'Peanut Butter', '500g jar of smooth peanut butter.', 'https://www.themealdb.com/images/ingredients/Peanut%20Butter.png', 'Pantry');
INSERT INTO public.products VALUES ('e8e8d839-5069-4c0d-b24c-f853bc4217ea', 'Jam', 'Jar of strawberry jam.', 'https://www.themealdb.com/images/ingredients/Jam.png', 'Pantry');
INSERT INTO public.products VALUES ('486c2412-eb25-4218-87f5-d5156232e1be', 'Honey', 'Jar of clear honey.', 'https://www.themealdb.com/images/ingredients/Honey.png', 'Pantry');
INSERT INTO public.products VALUES ('34cedb63-f4f7-4edb-90c8-a7b298563dc1', 'Coffee', '250g bag of ground coffee.', 'https://www.themealdb.com/images/ingredients/Coffee.png', 'Beverages');
INSERT INTO public.products VALUES ('1f129965-7c32-46f1-8043-d5e1dc457ddf', 'Tea Bags', 'Box of 100 black tea bags.', 'https://www.themealdb.com/images/ingredients/Tea.png', 'Beverages');
INSERT INTO public.products VALUES ('c2ea15dc-aef7-48e8-bb85-fdfb7fe6dfa3', 'Sugar', '1kg bag of granulated sugar.', 'https://www.themealdb.com/images/ingredients/Sugar.png', 'Pantry');
INSERT INTO public.products VALUES ('15ce6f31-65c3-428e-94c0-fa9c8f3dedf4', 'Flour', '1.5kg bag of plain flour.', 'https://www.themealdb.com/images/ingredients/Flour.png', 'Pantry');
INSERT INTO public.products VALUES ('d8f51b3e-684f-4732-9f01-a6f9f59bd457', 'Olive Oil', '500ml bottle of extra virgin olive oil.', 'https://www.themealdb.com/images/ingredients/Olive%20Oil.png', 'Pantry');
INSERT INTO public.products VALUES ('3b8e5d81-82c7-41a0-bd4b-c7cfb461f5c2', 'Vinegar', '500ml bottle of white wine vinegar.', 'https://www.themealdb.com/images/ingredients/Vinegar.png', 'Pantry');
INSERT INTO public.products VALUES ('832800a2-25e1-4e54-b7ce-28d6a5afaf78', 'Salt', '750g tub of table salt.', 'https://www.themealdb.com/images/ingredients/Salt.png', 'Pantry');
INSERT INTO public.products VALUES ('430a7305-4752-4fe3-9cdc-fe597f952aa6', 'Black Pepper', '50g grinder of black peppercorns.', 'https://www.themealdb.com/images/ingredients/Pepper.png', 'Pantry');
INSERT INTO public.products VALUES ('17940a86-2fd2-45be-baa8-5a0a16637a49', 'Herbs', 'Jar of mixed dried herbs.', 'https://www.themealdb.com/images/ingredients/Basil.png', 'Pantry');
INSERT INTO public.products VALUES ('c638b031-8ce6-4332-ab04-f86d176cc352', 'Spices', 'Jar of paprika.', 'https://www.themealdb.com/images/ingredients/Paprika.png', 'Pantry');
INSERT INTO public.products VALUES ('c8c7b360-738a-49a8-bc10-1b8bbcda85b5', 'Chocolate', '100g bar of dark chocolate.', 'https://www.themealdb.com/images/ingredients/Dark%20Chocolate.png', 'Snacks');
INSERT INTO public.products VALUES ('dadd75dc-ecdb-4e8a-b1de-f2c9350df253', 'Biscuits', 'Pack of digestive biscuits.', 'https://www.themealdb.com/images/ingredients/Biscuits.png', 'Snacks');
INSERT INTO public.products VALUES ('aecb6c16-92e3-4a77-8c95-884684d2cf4f', 'Crisps', 'Bag of ready salted crisps.', 'https://www.themealdb.com/images/ingredients/Potatoes.png', 'Snacks');
INSERT INTO public.products VALUES ('9f290f8f-fec5-4785-96e1-5597040b27ec', 'Soda', 'Can of cola.', 'https://www.themealdb.com/images/ingredients/Water.png', 'Beverages');
INSERT INTO public.products VALUES ('5dc537bc-9be7-46f7-884f-55f6c85c9d90', 'Beer', 'Bottle of lager.', 'https://www.themealdb.com/images/ingredients/Beer.png', 'Beverages');
INSERT INTO public.products VALUES ('2d683dfb-e807-43fa-b21c-960941875201', 'Wine', 'Bottle of red wine.', 'https://www.themealdb.com/images/ingredients/Wine.png', 'Beverages');
INSERT INTO public.products VALUES ('ae9fa833-062c-43cd-843f-5122701bce88', 'Cereal', 'Box of corn flakes.', 'https://www.themealdb.com/images/ingredients/Oats.png', 'Pantry');
INSERT INTO public.products VALUES ('baf6fe68-213a-4393-8443-0ba92600b7c0', 'Ice Cream', 'Tub of vanilla ice cream.', 'https://www.themealdb.com/images/ingredients/Ice%20Cream.png', 'Frozen');
INSERT INTO public.products VALUES ('7e8d7de7-c100-4ff8-a5cf-d59f3a356c83', 'Pizza', 'Frozen margherita pizza.', 'https://www.themealdb.com/images/ingredients/Pizza.png', 'Frozen');
INSERT INTO public.products VALUES ('e2e996e3-caae-4eb4-8e37-a2b6e2c57b68', 'Yogurt Drinks', 'Pack of 4 strawberry yogurt drinks.', 'https://www.themealdb.com/images/ingredients/Yogurt.png', 'Dairy & Eggs');
INSERT INTO public.products VALUES ('e19e512a-ba1d-4fa7-bc5a-1a309eceb384', 'Tofu', '300g block of firm tofu.', 'https://www.themealdb.com/images/ingredients/Tofu.png', 'Pantry');
INSERT INTO public.products VALUES ('057fc9d7-fb45-4422-afbf-1b825615c1f4', 'Nuts', 'Bag of mixed nuts.', 'https://www.themealdb.com/images/ingredients/Almonds.png', 'Snacks');
INSERT INTO public.products VALUES ('962dd9b4-0be2-4b29-8c45-a3a1649f9a92', 'Dried Fruit', 'Bag of mixed dried fruit.', 'https://www.themealdb.com/images/ingredients/Dates.png', 'Snacks');
INSERT INTO public.products VALUES ('11822f73-06c7-462e-91e8-084116667482', 'Protein Bar', 'Chocolate flavour protein bar.', 'https://www.themealdb.com/images/ingredients/Chocolate.png', 'Snacks');
INSERT INTO public.products VALUES ('a311d71a-07a1-4e7f-acc1-7c04ff872e58', 'Ketchup', 'Bottle of tomato ketchup.', 'https://www.themealdb.com/images/ingredients/Tomato%20Puree.png', 'Pantry');
INSERT INTO public.products VALUES ('fa190909-2859-4867-acf1-841ec9f6477d', 'Mayonnaise', 'Jar of mayonnaise.', 'https://www.themealdb.com/images/ingredients/Mayonnaise.png', 'Pantry');
INSERT INTO public.products VALUES ('1e4b2021-40b8-469a-9be0-e3159d9e7b1f', 'Mustard', 'Jar of English mustard.', 'https://www.themealdb.com/images/ingredients/Mustard.png', 'Pantry');
INSERT INTO public.products VALUES ('d474fcf5-447e-469f-b9ab-c4093b2daa3b', 'Salsa', 'Jar of mild salsa.', 'https://www.themealdb.com/images/ingredients/Tomato.png', 'Pantry');
INSERT INTO public.products VALUES ('8d6414ad-2020-4788-881a-7cb5195c52d6', 'Tortilla Chips', 'Bag of salted tortilla chips.', 'https://www.themealdb.com/images/ingredients/Tortillas.png', 'Snacks');
INSERT INTO public.products VALUES ('c915b1e7-a218-4fef-82f8-d215f5b45229', 'Wraps', 'Pack of 8 tortilla wraps.', 'https://www.themealdb.com/images/ingredients/Tortillas.png', 'Bakery');
INSERT INTO public.products VALUES ('81f00c45-688e-4800-a10d-f26305ccc7ee', 'Bagels', 'Pack of 4 plain bagels.', 'https://www.themealdb.com/images/ingredients/Bread.png', 'Bakery');
INSERT INTO public.products VALUES ('05d9e9af-d5f4-4b3d-9b93-301fd50c2dd6', 'Croissants', 'Pack of 2 all-butter croissants.', 'https://www.themealdb.com/images/ingredients/Croissants.png', 'Bakery');
INSERT INTO public.products VALUES ('de12e45b-fcfe-4d52-bb47-72f428d60fe0', 'Muffins', 'Pack of 4 blueberry muffins.', 'https://www.themealdb.com/images/ingredients/Muffins.png', 'Bakery');
INSERT INTO public.products VALUES ('d3a46945-056d-4710-866d-be76ddec88e5', 'Doughnuts', 'Pack of 4 glazed ring doughnuts.', 'https://www.themealdb.com/images/ingredients/Sugar.png', 'Bakery');
INSERT INTO public.products VALUES ('db7d9c14-88da-424b-b8d8-256cf6a74a51', 'Pancakes', 'Pack of 6 ready-made pancakes.', 'https://www.themealdb.com/images/ingredients/Pancakes.png', 'Bakery');
INSERT INTO public.products VALUES ('8c004d98-a33e-483d-a3d4-dd4390107dc3', 'Waffles', 'Pack of 4 frozen waffles.', 'https://www.themealdb.com/images/ingredients/Pancakes.png', 'Frozen');
INSERT INTO public.products VALUES ('e72be74f-78f7-4f34-b096-d0c33397fcf5', 'Syrup', 'Bottle of maple syrup.', 'https://www.themealdb.com/images/ingredients/Maple%20Syrup.png', 'Pantry');
INSERT INTO public.products VALUES ('b37c8098-bdf8-4f61-8c34-2557804ef8c8', 'Couscous', 'Box of instant couscous.', 'https://www.themealdb.com/images/ingredients/Couscous.png', 'Pantry');
INSERT INTO public.products VALUES ('640bf2b5-d762-4193-9938-5ce02e8f9e5d', 'Noodles', 'Pack of instant noodles.', 'https://www.themealdb.com/images/ingredients/Noodles.png', 'Pantry');
INSERT INTO public.products VALUES ('cd4fc9be-550c-42e8-84f3-e7f48d323438', 'Soy Sauce', 'Bottle of light soy sauce.', 'https://www.themealdb.com/images/ingredients/Soy%20Sauce.png', 'Pantry');
INSERT INTO public.products VALUES ('0f4de78a-46ef-45dc-9067-ff4157c3beb5', 'Sweet Chilli Sauce', 'Bottle of sweet chilli sauce.', 'https://www.themealdb.com/images/ingredients/Chilli.png', 'Pantry');
INSERT INTO public.products VALUES ('b2ce73d5-ad42-4af0-b0f7-b1334b8c0992', 'Coconut Milk', 'Can of coconut milk.', 'https://www.themealdb.com/images/ingredients/Coconut%20Milk.png', 'Pantry');
INSERT INTO public.products VALUES ('50f43147-1395-4196-bcb2-96dd9e9870c0', 'Curry Paste', 'Jar of red Thai curry paste.', 'https://www.themealdb.com/images/ingredients/Curry.png', 'Pantry');
INSERT INTO public.products VALUES ('6eb14c35-0a4e-44f5-9142-1d397664564c', 'Stock Cubes', 'Box of vegetable stock cubes.', 'https://www.themealdb.com/images/ingredients/Stock.png', 'Pantry');
INSERT INTO public.products VALUES ('cd49db01-e2a3-41fc-b7fe-95cebfd419cf', 'Gravy Granules', 'Tub of gravy granules.', 'https://www.themealdb.com/images/ingredients/Gravy.png', 'Pantry');
INSERT INTO public.products VALUES ('034639a3-c67d-4266-9be9-d46bf41fdcf0', 'Tinned Tomatoes', 'Can of chopped tomatoes.', 'https://www.themealdb.com/images/ingredients/Canned%20Tomatoes.png', 'Pantry');
INSERT INTO public.products VALUES ('0fd7a0eb-779e-4963-985b-3c791ed9e21e', 'Baked Beans', 'Can of baked beans in tomato sauce.', 'https://www.themealdb.com/images/ingredients/Baked%20Beans.png', 'Pantry');
INSERT INTO public.products VALUES ('e978e5ec-099a-478e-b40a-1f13e015eabd', 'Spaghetti Hoops', 'Can of spaghetti hoops in tomato sauce.', 'https://www.themealdb.com/images/ingredients/Pasta.png', 'Pantry');
INSERT INTO public.products VALUES ('098eeec0-55d1-4495-bfd6-87cb865ec9dd', 'Hot Dogs', 'Jar of hot dogs in brine.', 'https://www.themealdb.com/images/ingredients/Sausages.png', 'Pantry');
INSERT INTO public.products VALUES ('eb242ce9-174f-40ea-b9b8-754757df882a', 'Burgers', 'Pack of 4 beef burgers.', 'https://www.themealdb.com/images/ingredients/Beef.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('9705f024-44dd-4117-87a8-03eed1b1ce8e', 'Sausages', 'Pack of 8 pork sausages.', 'https://www.themealdb.com/images/ingredients/Sausages.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('b08d56ab-ef1a-4a31-abc8-513b8b5574f2', 'Bacon', 'Pack of rashers of back bacon.', 'https://www.themealdb.com/images/ingredients/Bacon.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('f2b15e8b-30c9-4fc4-b1da-af8b922ae42c', 'Ham', 'Pack of sliced ham.', 'https://www.themealdb.com/images/ingredients/Ham.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('c207dfea-25f0-484c-8b28-92e4b7b87ae6', 'Salami', 'Pack of sliced salami.', 'https://www.themealdb.com/images/ingredients/Salami.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('0fe7e157-33da-4a9b-8716-abc1f29f1d92', 'Chorizo', 'Ring of chorizo.', 'https://www.themealdb.com/images/ingredients/Chorizo.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('d5fc9b3a-7943-4ee2-8459-3fd2f22ac0fb', 'Prawns', 'Bag of cooked and peeled prawns.', 'https://www.themealdb.com/images/ingredients/Prawns.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('709c6eee-4cab-46a4-a536-9ac24fd7b9af', 'Mussels', 'Bag of fresh mussels.', 'https://www.themealdb.com/images/ingredients/Mussels.png', 'Meat & Seafood');
INSERT INTO public.products VALUES ('9198554f-d2e4-4013-9cdd-7f4c712d87ec', 'Squid', 'Bag of frozen squid rings.', 'https://www.themealdb.com/images/ingredients/Squid.png', 'Frozen');
INSERT INTO public.products VALUES ('4b8cdbf4-6dd1-4f87-b958-272e70065efb', 'Fish Cakes', 'Pack of 2 cod fish cakes.', 'https://www.themealdb.com/images/ingredients/Fish.png', 'Frozen');
INSERT INTO public.products VALUES ('7b9cb7b7-d248-4c80-9210-e8e99dcc080f', 'Spring Rolls', 'Pack of 10 vegetable spring rolls.', 'https://www.themealdb.com/images/ingredients/Spring%20Rolls.png', 'Frozen');
INSERT INTO public.products VALUES ('6022de13-f5e9-44e9-bbec-b1c306d61fa2', 'Samosas', 'Pack of 4 vegetable samosas.', 'https://www.themealdb.com/images/ingredients/Samosas.png', 'Frozen');
INSERT INTO public.products VALUES ('5f926303-91b6-42b7-b5a8-6ef83cffe30c', 'Onion Bhajis', 'Pack of 4 onion bhajis.', 'https://www.themealdb.com/images/ingredients/Onion.png', 'Frozen');
INSERT INTO public.products VALUES ('12e517db-ae33-4911-94e8-89a9dd65b5e6', 'Pakoras', 'Pack of vegetable pakoras.', 'https://www.themealdb.com/images/ingredients/Chicken.png', 'Frozen');
INSERT INTO public.products VALUES ('8b469bf0-6d3a-4df5-9973-2448b04a1c99', 'Coleslaw', 'Tub of coleslaw.', 'https://www.themealdb.com/images/ingredients/Cabbage.png', 'Pantry');
INSERT INTO public.products VALUES ('63fa1e3a-1d32-4c75-882c-3747fd1f7eaf', 'Potato Salad', 'Tub of potato salad.', 'https://www.themealdb.com/images/ingredients/Potatoes.png', 'Pantry');
INSERT INTO public.products VALUES ('9cadc915-4928-49c4-9caf-660af5ccf3d3', 'Hummus', 'Tub of hummus.', 'https://www.themealdb.com/images/ingredients/Hummus.png', 'Pantry');
INSERT INTO public.products VALUES ('fbc3146e-7e57-4ea3-bb00-32794990cd9d', 'Guacamole', 'Tub of guacamole.', 'https://www.themealdb.com/images/ingredients/Avocado.png', 'Pantry');
INSERT INTO public.products VALUES ('17cc6e07-1240-485d-96c3-f7de53614fc8', 'Dips', 'Selection of dips.', 'https://www.themealdb.com/images/ingredients/Sour%20Cream.png', 'Pantry');
INSERT INTO public.products VALUES ('1909026d-d71a-4d55-9517-83d0d3a8655f', 'Olives', 'Jar of green olives.', 'https://www.themealdb.com/images/ingredients/Olives.png', 'Pantry');
INSERT INTO public.products VALUES ('5d696cfc-38b6-4240-bf23-7878faabc129', 'Sun-Dried Tomatoes', 'Jar of sun-dried tomatoes in oil.', 'https://www.themealdb.com/images/ingredients/Tomatoes.png', 'Pantry');
INSERT INTO public.products VALUES ('afc6d5bf-3c0e-43ee-ac50-3e1e00bdb92b', 'Artichoke Hearts', 'Can of artichoke hearts in water.', 'https://www.themealdb.com/images/ingredients/Artichokes.png', 'Pantry');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- PostgreSQL database dump complete
--

\unrestrict tAoww3FzEsdnAoJVVOPvtW5iM5sn95I21uzEfMKFkcKPimwXzX2jvJUZ72DDjFo

