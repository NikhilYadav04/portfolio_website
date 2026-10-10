// Bridge between the Flutter app and the mascot renderer.
//
// The mascot is drawn by @bible-strong/avatar-web (Bible Strong Avatar Lab by
// Stéphane Montlouis-Calixte, AGPL-3.0). Flutter can't import npm packages, so
// the app calls `window.nyMascot` instead; see lib/widgets/mascot/.
//
// A classic script, loaded before Flutter starts, so `nyMascot` always exists
// by the time the app asks for it. The renderer itself (about 57KB gzipped) is
// only downloaded on the first mount.
//
// strobi.avatar.json is generated: edit tool/mascot/build_strobi.py, not it.
(function () {
  // Exact versions all the way down: the package is pre-1.0, so a minor
  // release may break its API.
  var LIB = 'https://cdn.jsdelivr.net/npm/@bible-strong/avatar-web@0.1.0/+esm';
  var DEF = new URL('strobi.avatar.json', document.currentScript.src).href;

  var ready = null;
  function load() {
    if (!ready) {
      ready = Promise.all([
        import(LIB),
        fetch(DEF).then(function (r) {
          if (!r.ok) throw new Error('mascot definition: HTTP ' + r.status);
          return r.json();
        }),
      ]);
      // Let a later mount retry after a failed load (offline, CDN down).
      ready.catch(function () { ready = null; });
    }
    return ready;
  }

  // element -> controller, for every mascot on screen (desktop panel, sheet).
  var live = new Map();
  // What the app wants now: an animation, or a single expression (a cursor
  // look). A mount that finishes loading later starts on this.
  var current = { kind: 'animation', key: 'midday-sleeping' };

  function apply(c) {
    if (current.kind === 'expression') c.setExpression(current.key);
    else c.play(current.key);
  }

  window.nyMascot = {
    /** Set by the app: called when a visitor clicks or taps a mascot. */
    onTap: null,

    // Starts on whatever play() / look() last asked for.
    mount: function (el) {
      el.style.cursor = 'pointer';
      el.addEventListener('click', function () {
        if (typeof window.nyMascot.onTap === 'function') window.nyMascot.onTap();
      });
      load().then(function (res) {
        // Unmounted while loading.
        if (live.has(el) || el.dataset.unmounted) return;
        var controller = res[0].createAvatar(el, {
          definition: res[1],
          autoplay: true,
          size: '100%',
          ariaLabel: 'Strobi, the site mascot',
        });
        live.set(el, controller);
        apply(controller);
      }).catch(function (e) {
        // A missing mascot is decoration lost, not a broken site.
        console.warn('Mascot unavailable:', e);
      });
    },

    /** Play a looping or one-shot animation, e.g. "storm-mood". */
    play: function (animation) {
      current = { kind: 'animation', key: animation };
      live.forEach(apply);
    },

    /** Hold one expression, e.g. "midday-look-up-left" (smooth turn). */
    look: function (expression) {
      current = { kind: 'expression', key: expression };
      live.forEach(apply);
    },

    unmount: function (el) {
      el.dataset.unmounted = '1';
      var c = live.get(el);
      if (c) c.destroy();
      live.delete(el);
    },
  };
})();
