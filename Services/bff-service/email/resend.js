const { Resend } = require('resend');

function getResendClient() {
  const apiKey = process.env.RESEND_API_KEY;
  if (!apiKey) return null;
  return new Resend(apiKey);
}

async function sendWelcomeEmail({ to, firstName }) {
  const resend = getResendClient();
  if (!resend) {
    console.warn('RESEND_API_KEY is not set; skipping welcome email.');
    return;
  }

  if (typeof to !== 'string' || to.trim() === '') return;
  if (typeof firstName !== 'string' || firstName.trim() === '') return;

  const from = process.env.RESEND_FROM || 'onboarding@grocersave.app';
  const templateId = process.env.RESEND_WELCOME_TEMPLATE_ID || 'welcome';

  const { error } = await resend.emails.send({
    from,
    to: [to],
    template: {
      id: templateId,
      variables: { firstName }
    }
  });

  if (error) {
    throw new Error(typeof error === 'string' ? error : JSON.stringify(error));
  }
}

module.exports = { sendWelcomeEmail };

