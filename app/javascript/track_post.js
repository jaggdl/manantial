document.addEventListener('turbo:load', function() {
  const postIdMeta = document.querySelector('meta[name="post-id"]');
  if (postIdMeta) {
    ahoy.track("Viewed post", { post_id: postIdMeta.content });
  }
});
