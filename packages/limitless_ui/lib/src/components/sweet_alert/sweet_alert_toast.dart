import 'dart:async';
import 'dart:html';

class SweetAlertSimpleToast {
  /// [duration] in milliseconds
  static void showWarningToast(String message, {int? duration = 3000}) async {
    var template = '''
   <div aria-labelledby="swal2-title" aria-describedby="swal2-html-container" class="swal2-popup swal2-toast swal2-icon-warning swal2-show" tabindex="-1" role="alert" aria-live="polite" style="width: 100%; display: grid;">
           
      <div class="swal2-loader"></div>
      <div class="swal2-icon swal2-warning swal2-icon-show" style="display: flex;">
         <div class="swal2-icon-content">!</div>
      </div>            
      <div class="swal2-html-container" id="swal2-html-container" style="display: block;">$message</div>   
      <div class="swal2-timer-progress-bar-container">
         <div class="swal2-timer-progress-bar" ></div>
      </div>
   </div>
  ''';

    document.querySelector('#swal2-toast-14569')?.remove();

    final root = DivElement();
    root.attributes['class'] = 'swal2-container swal2-top swal2-backdrop-show';
    root.attributes['style'] = 'overflow-y: auto;';
    root.style.zIndex = '3000';
    root.id = 'swal2-toast-14569';

    root.onClick.listen((event) {
      root.remove();
      document.body?.classes.removeAll(['swal2-toast-shown', 'swal2-shown']);
    });

    document.body?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: NodeTreeSanitizer.trusted);
    document.body?.classes.addAll(['swal2-toast-shown', 'swal2-shown']);

    await Future.delayed(Duration(milliseconds: 100));

    var documentWidth = root
        .querySelector('.swal2-timer-progress-bar-container')!
        .getBoundingClientRect()
        .width as double;

    var progressBar =
        root.querySelector('.swal2-timer-progress-bar') as DivElement;

    var start = DateTime.now();
    if (duration != null) {
      //Future.delayed(timeout, () => root.remove());
      Timer.periodic(Duration(milliseconds: 30), (timer) {
        var diff = duration - DateTime.now().difference(start).inMilliseconds;
        diff = diff < 0 ? 0 : diff;
        var progresBarWidth = (diff * documentWidth / duration);
        progresBarWidth = progresBarWidth < 0 ? 0 : progresBarWidth;
        progressBar.style.width = '${progresBarWidth}px';
        // print('diff $diff | $progresBarWidth | $documentWidth');
        if (diff <= 0) {
          timer.cancel();
          root.remove();
        }
      });
    }
  }

  static void showSuccessToast(String message, {int? duration = 3000}) async {
    var template = '''
    <div aria-labelledby="swal2-title" aria-describedby="swal2-html-container" class="swal2-popup swal2-toast swal2-icon-success swal2-show" tabindex="-1" role="alert" aria-live="polite" style="width: 100%; display: grid;">
             <div class="swal2-loader"></div>
        <div class="swal2-icon swal2-success swal2-icon-show" style="display: flex;">
            <div class="swal2-success-circular-line-left" style="background-color: rgb(255, 255, 255);"></div>
            <span class="swal2-success-line-tip"></span> <span class="swal2-success-line-long"></span>
            <div class="swal2-success-ring"></div>
            <div class="swal2-success-fix" style="background-color: rgb(255, 255, 255);"></div>
            <div class="swal2-success-circular-line-right" style="background-color: rgb(255, 255, 255);"></div>
        </div>     
        <div class="swal2-html-container" id="swal2-html-container" style="display: block;">$message</div>            
        <div class="swal2-timer-progress-bar-container">
        <div class="swal2-timer-progress-bar" >
        </div></div>
    </div>
  ''';
    document.querySelector('#swal2-toast-14569')?.remove();

    var root = DivElement();
    root.attributes['class'] =
        'swal2-container swal2-top-end swal2-backdrop-show';
    root.attributes['style'] = 'overflow-y: auto;';
    root.style.zIndex = '3000';
    root.id = 'swal2-toast-14569';

    root.onClick.listen((event) {
      root.remove();
    });

    document.body?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: NodeTreeSanitizer.trusted);
    document.body?.classes.addAll(['swal2-toast-shown', 'swal2-shown']);

    await Future.delayed(Duration(milliseconds: 100));

    var documentWidth = root
        .querySelector('.swal2-timer-progress-bar-container')!
        .getBoundingClientRect()
        .width as double;

    var progressBar =
        root.querySelector('.swal2-timer-progress-bar') as DivElement;

    var start = DateTime.now();
    if (duration != null) {
      //Future.delayed(timeout, () => root.remove());
      Timer.periodic(Duration(milliseconds: 30), (timer) {
        var diff = duration - DateTime.now().difference(start).inMilliseconds;
        diff = diff < 0 ? 0 : diff;
        var progresBarWidth = (diff * documentWidth / duration);
        progresBarWidth = progresBarWidth < 0 ? 0 : progresBarWidth;
        progressBar.style.width = '${progresBarWidth}px';
        // print('diff $diff | $progresBarWidth | $documentWidth');
        if (diff <= 0) {
          timer.cancel();
          root.remove();
        }
      });
    }
  }
}
