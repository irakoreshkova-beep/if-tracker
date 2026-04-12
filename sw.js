const CACHE = 'if-tracker-v11';
const ASSETS = ['./', './index.html', './manifest.json', './icon.png'];

self.addEventListener('message', function(e) {
  if (e.data && e.data.type === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});

self.addEventListener('install', function(e) {
  e.waitUntil(caches.open(CACHE).then(function(c) { return c.addAll(ASSETS); }));
});

self.addEventListener('activate', function(e) {
  e.waitUntil(caches.keys().then(function(keys) {
    return Promise.all(keys.filter(function(k) { return k !== CACHE; }).map(function(k) { return caches.delete(k); }));
  }));
  self.clients.claim();
});

self.addEventListener('fetch', function(e) {
  e.respondWith(
    fetch(e.request).then(function(res) {
      return caches.open(CACHE).then(function(c) {
        c.put(e.request, res.clone());
        return res;
      });
    }).catch(function() {
      return caches.match(e.request).then(function(r) {
        return r || caches.match('./index.html');
      });
    })
  );
});
