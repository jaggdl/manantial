import "ahoy"

ahoy.configure({cookies: false});

document.addEventListener('turbo:load', () => {
  ahoy.trackView();
});
