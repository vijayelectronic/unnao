// Vijay Electronics Unnao - JS
(function(){
  const root = document.documentElement;

  // Initialize theme
  const savedTheme = localStorage.getItem('ve_theme') || 'light';
  root.setAttribute('data-theme', savedTheme);
  const themeToggle = document.getElementById('themeToggle');
  if (themeToggle) {
    themeToggle.addEventListener('click', () => {
      const next = root.getAttribute('data-theme') === 'light' ? 'dark' : 'light';
      root.setAttribute('data-theme', next);
      localStorage.setItem('ve_theme', next);
    });
  }

  // Initialize language (English default)
  const savedLang = localStorage.getItem('ve_lang') || 'en';
  root.setAttribute('data-lang', savedLang);
  const langToggle = document.getElementById('langToggle');
  if (langToggle) {
    langToggle.addEventListener('click', () => {
      const next = root.getAttribute('data-lang') === 'en' ? 'hi' : 'en';
      root.setAttribute('data-lang', next);
      localStorage.setItem('ve_lang', next);
    });
  }

  // Auto slider on homepage
  const slider = document.getElementById('slider');
  if (slider) {
    const slides = Array.from(slider.querySelectorAll('.slide'));
    let idx = 0;
    setInterval(() => {
      slides[idx].classList.remove('active');
      idx = (idx + 1) % slides.length;
      slides[idx].classList.add('active');
    }, 3500);
  }

  // Contact form: Formspree + WhatsApp auto-message
  const contactForm = document.getElementById('contactForm');
  if (contactForm) {
    // Put your Formspree form ID here (e.g., "xaylbwrg").
    // Create it at https://formspree.io/ and paste the ID below.
    const FORMSPREE_ID = '';
    const toWhatsApp = (data) => {
      const phone = '918090090051'; // with country code
      const text = encodeURIComponent(
        `New enquiry from website\nName: ${data.name}\nPhone: ${data.phone}\nEmail: ${data.email || '-'}\nMessage: ${data.message}`
      );
      window.open(`https://wa.me/${phone}?text=${text}`, '_blank');
    };

    contactForm.addEventListener('submit', async (e) => {
      e.preventDefault();
      const formData = Object.fromEntries(new FormData(contactForm).entries());

      // Fire WhatsApp auto-message immediately
      toWhatsApp(formData);

      // If Formspree ID is present, post to Formspree to send email
      if (FORMSPREE_ID) {
        try {
          const res = await fetch(`https://formspree.io/f/${FORMSPREE_ID}`, {
            method: 'POST',
            headers: { 'Accept': 'application/json' },
            body: new FormData(contactForm)
          });
          if (res.ok) {
            alert('Thanks! Your details were sent. We will contact you soon.');
            contactForm.reset();
          } else {
            alert('Form submit failed. Please WhatsApp or call us.');
          }
        } catch (err) {
          alert('Network error. Please WhatsApp or call us.');
        }
      } else {
        alert('Submitted! WhatsApp message opened. To receive email alerts, set FORMSPREE_ID in assets/js/main.js');
      }
    });
  }
})();