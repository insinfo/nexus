import 'dart:async';
import 'dart:html';
import 'dart:math' as math;

class SimpleLoading {
  Element _root = DivElement();
  Element? _spinner;
  Element? _target;

  StreamSubscription<Event>? _winScrollSub;
  StreamSubscription<Event>? _containerScrollSub;
  StreamSubscription<Event>? _resizeSub;
  ResizeObserver? _ro;

  double _safeMargin = 64; // px
  EventTarget? _scrollContainer;

  String _overlayColor() {
    final theme = document.documentElement?.attributes['data-color-theme'];
    return theme == 'dark' ? 'rgb(0 0 0 / 36%)' : 'rgb(255 255 255 / 48%)';
  }

  void showOnBody() => show(target: null);

  void show({Element? target, double safeMargin = 64}) {
    _safeMargin = safeMargin;

    _target = target ?? document.body;

    // overlay
    _root = DivElement()
      ..style.position = (target != null) ? 'absolute' : 'fixed'
      ..style.left = '0'
      ..style.top = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.background = _overlayColor()
      ..style.zIndex = '500000';

    // ancoragem do absolute no target
    if (target != null && target.getComputedStyle().position == 'static') {
      target.style.position = 'relative';
    }

    // spinner
    _spinner = DivElement()
      ..setInnerHtml(
        '<i class="ph-spinner ph-3x spinner text-primary"></i>',
        treeSanitizer: NodeTreeSanitizer.trusted,
      )
      ..style.position = 'absolute'
      ..style.left = '50%'
      ..style.transform = 'translateX(-50%)';
    _spinner!.style.pointerEvents = 'none'; // deixa clique “morrer” no overlay

    _root.append(_spinner!);

    if (target != null) {
      target.append(_root);
    } else {
      document.body?.append(_root);
    }

    // quem rola de verdade?
    _scrollContainer = _findScrollableAncestor(_target!);

    // listeners
    _winScrollSub = window.onScroll.listen((_) => _rafUpdate());

    if (_scrollContainer is Element) {
      _containerScrollSub =
          (_scrollContainer as Element).onScroll.listen((_) => _rafUpdate());
    }

    _resizeSub = window.onResize.listen((_) => _rafUpdate());

    // observa mudanças de tamanho do target
    _ro = ResizeObserver((List<dynamic> entries, ResizeObserver observer) {
      _rafUpdate();
    })
      ..observe(_target!);

    _rafUpdate();
  }

  void _rafUpdate() {
    if (_target != null && _target!.isConnected == true) {
      window.requestAnimationFrame((_) => _updateSpinnerPosition());
    } else {
      hide();
    }
  }

  void _updateSpinnerPosition() {
    if (_spinner == null || _target == null) return;

    final Rectangle<num> rect =
        (_target == document.body || _target == document.documentElement)
            ? Rectangle<num>(
                0,
                0,
                (window.innerWidth ?? 0).toDouble(),
                (document.documentElement?.scrollHeight ?? 0).toDouble(),
              )
            : _target!.getBoundingClientRect();

    final double viewportH = (window.innerHeight ?? 0).toDouble();

    // centro do alvo (em coords de viewport)
    final double centerYViewport = (rect.top + rect.height / 2).toDouble();

    // manter dentro de uma faixa visível
    final double topClamp = _safeMargin;
    final double bottomClamp = viewportH - _safeMargin;
    final double clampedY =
        math.max(topClamp, math.min(centerYViewport, bottomClamp));

    // converter para coords relativas ao target/overlay
    final double topInTarget = clampedY - rect.top.toDouble();

    _spinner!.style.top = '${topInTarget}px';
  }

  void hide() {
    _winScrollSub?.cancel();
    _containerScrollSub?.cancel();
    _resizeSub?.cancel();
    _ro?.disconnect();

    _winScrollSub = null;
    _containerScrollSub = null;
    _resizeSub = null;
    _ro = null;

    _spinner = null;
    _target = null;
    _scrollContainer = null;

    _root.remove();
  }

  /// encontra o ancestral que rola (overflow-y: auto|scroll). Pode ser o `window`.
  EventTarget _findScrollableAncestor(Element start) {
    Element? el = start;
    while (el != null && el != document.body) {
      final oy = el.getComputedStyle().overflowY;
      if (oy == 'auto' || oy == 'scroll') return el;
      el = el.parent;
    }
    return window; // fallback
  }

  void showSimple({Element? target}) {
    _root = DivElement();
    _root.style.width = '100%';
    _root.style.height = '100%';
    _root.style.background = _overlayColor();
    _root.style.position = 'absolute';
    _root.style.left = '0';
    _root.style.top = '0';
    _root.style.zIndex = '50000';
    _root.style.display = 'flex';
    _root.style.flexDirection = 'column';
    _root.style.alignItems = 'center';
    _root.style.justifyContent = 'center';

    _root.appendHtml('''
<div>
<i class="ph-spinner ph-3x spinner text-primary"></i>
</div>
''');

    if (target != null) {
      target.append(_root);
    } else {
      document.querySelector('body')?.append(_root);
    }
  }

  void showHorizontal({Element? target}) {
    _root = DivElement();
    _root.style.width = '100%';
    _root.style.position = 'absolute';
    _root.style.left = '0';
    _root.style.top = '0';
    _root.style.zIndex = '50000';

    var backColor = '#2196f3';
    var frontColor = '#fff';

    // ignore: unsafe_html
    _root.setInnerHtml('''
<style>
.loader { 
  width:100%; 
  margin:0 auto; 
  position:relative;
  padding:0;
  height: 3px;
  background-color: $backColor; 
}
.loader:before {
  content:'';
  position:absolute;
  top:0; 
  right:0; 
  bottom:0; 
  left:0;
}
.loader .loaderBar { 
  position:absolute;
  height: 3px;
  border-radius:0;
  top:0;
  right:100%;
  bottom:0;
  left:0;
  background: $frontColor; 
  width:0;
  animation:borealisBar 2s linear infinite;
}
@keyframes borealisBar {
  0% {
    left:0%;
    right:100%;
    width:0%;
  }
  10% {
    left:0%;
    right:75%;
    width:25%;
  }
  90% {
    right:0%;
    left:75%;
    width:25%;
  }
  100% {
    left:100%;
    right:0%;
    width:0%;
  }
}
</style>
<div class="loader">
  <div class="loaderBar"></div>
</div>
''', treeSanitizer: NodeTreeSanitizer.trusted);

    if (target != null) {
      target.append(_root);
    } else {
      document.querySelector('body')?.append(_root);
    }
  }

  void showHorizontal2({Element? target}) {
    _root = DivElement();
    _root.style.width = '100%';
    _root.style.position = 'absolute';
    _root.style.left = '0';
    _root.style.top = '0';
    _root.style.zIndex = '50000';

    // ignore: unsafe_html
    _root.setInnerHtml(''' <style>
        .progress-container.indeterminate {
          background-color: #c6dafc
        }
        .progress-container {
          position: relative;
          height: 100%;
          background-color: #e0e0e0;
          overflow: hidden
        }
        .progress-container.indeterminate.fallback>.secondary-progress {
          animation-name: indeterminate-secondary-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        .progress-container.indeterminate>.secondary-progress {
          background-color: #4285f4
        }
        .secondary-progress {
          background-color: #a1c2fa
        }
        .active-progress,
        .secondary-progress {
          transform-origin: left center;
          transform: scaleX(0);
          position: absolute;
          top: 0;
          transition: transform 218ms cubic-bezier(.4, 0, .2, 1);
          right: 0;
          bottom: 0;
          left: 0;
          will-change: transform
        }
        .progress-container {
          position: relative;
          height: 100%;
          background-color: #e0e0e0;
          overflow: hidden
        }
        .progress-container.indeterminate {
          background-color: #c6dafc
        }
        .progress-container.indeterminate>.secondary-progress {
          background-color: #4285f4
        }
        .active-progress,
        .secondary-progress {
          transform-origin: left center;
          transform: scaleX(0);
          position: absolute;
          top: 0;
          transition: transform 218ms cubic-bezier(.4, 0, .2, 1);
          right: 0;
          bottom: 0;
          left: 0;
          will-change: transform
        }
        .active-progress {
          background-color: #4285f4
        }
        .secondary-progress {
          background-color: #a1c2fa
        }
        .progress-container.indeterminate.fallback>.active-progress {
          animation-name: indeterminate-active-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        .progress-container.indeterminate.fallback>.secondary-progress {
          animation-name: indeterminate-secondary-progress;
          animation-duration: 2s;
          animation-iteration-count: infinite;
          animation-timing-function: linear
        }
        @keyframes indeterminate-active-progress {
          0% {
            transform: translate(0) scaleX(0)
          }
          25% {
            transform: translate(0) scaleX(.5)
          }
          50% {
            transform: translate(25%) scaleX(.75)
          }
          75% {
            transform: translate(100%) scaleX(0)
          }
          100% {
            transform: translate(100%) scaleX(0)
          }
        }
        @keyframes indeterminate-secondary-progress {
          0% {
            transform: translate(0) scaleX(0)
          }
          60% {
            transform: translate(0) scaleX(0)
          }
          80% {
            transform: translate(0) scaleX(.6)
          }
          100% {
            transform: translate(100%) scaleX(.1)
          }
        }
        .loadContainer {
            width: 100%;          
        }
        .loadingC {
           width: 100%;
           height: 4px;               
        }
      </style>
      <div class="loadContainer">
        <div class="loadingC">
          <!--<span>Carregando...</span>-->
          <div class="progress-container _ngcontent-xao-51 indeterminate fallback" role="progressbar"
            aria-label="loading" aria-valuemin="0" aria-valuemax="100">
            <div class="secondary-progress _ngcontent-xao-51" aria-label="active progress 0 secondary progress 0"
              style="transform: scaleX(0);"></div>
            <div class="active-progress _ngcontent-xao-51" style="transform: scaleX(0);"></div>
          </div>
        </div>
      </div>''', treeSanitizer: NodeTreeSanitizer.trusted);

    if (target != null) {
      target.append(_root);
    } else {
      document.querySelector('body')?.append(_root);
    }
  }
}
