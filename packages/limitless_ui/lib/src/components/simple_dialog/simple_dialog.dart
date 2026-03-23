// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:html' as html;

enum DialogColor { DANGER, PRIMARY, SUCCESS, WARNING, INFO, PINK }

class SimpleDialogComponent {
  static String getColor(DialogColor dialogColor) {
    var headerColor = '';
    switch (dialogColor) {
      case DialogColor.PRIMARY:
        headerColor = 'primary';
        break;
      case DialogColor.SUCCESS:
        headerColor = 'success';
        break;
      case DialogColor.DANGER:
        headerColor = 'danger';
        break;
      case DialogColor.WARNING:
        headerColor = 'warning';
        break;
      case DialogColor.INFO:
        headerColor = 'info';
        break;
      case DialogColor.PINK:
        headerColor = 'pink';
        break;
    }
    return headerColor;
  }

  static void showFullScreenDialog(String content) {
    var template = '''
    <div style="width: 100%;height: 100%;display: block; 
    position: fixed;top: 0;left: 0;background: rgba(255, 255, 255, 0.5);">
    $content
    </div>
     ''';
    // ignore: omit_local_variable_types
    html.DivElement root = html.DivElement();
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
  }

  static void showFullScreenAlert(String message,
      {backgroundColor = '#de589d'}) {
    var template = '''
    <div style="width: 100%;height: 100%;display: block; 
        position: fixed;top: 0;left: 0;background: rgba(255, 255, 255, 0.5);">
        <div style="display:flex;align-items:center;justify-content:center;width: 100%;height: 100%;">
            <h1 style="width:50%;height:77px;text-align:center;background:$backgroundColor;color:#fff;padding:20px;">$message</h1>
        </div>
    </div>
     ''';
    html.document.querySelector('.FullScreenAlert')?.remove();
    // ignore: omit_local_variable_types
    html.DivElement root = html.DivElement();
    root.classes.add('FullScreenAlert');
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
  }

  static void showAlert(
    String message, {
    String? subMessage,
    String title = 'Alerta',
    String detailLabel = 'Detalhe',
    DialogColor dialogColor = DialogColor.PRIMARY,
    Function? okAction,
  }) {
    final template = '''
      <div class="modal fade show" tabindex="-1" role="dialog" style="padding-left: 0px; display: block;overflow: auto;" aria-modal="true" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">                
                <div class="modal-header bg-${getColor(dialogColor)} text-white border-0">
                  <h6 class="modal-title">$title</h6>
                  <!--<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>-->
							  </div>
                <div class="modal-body">
                    $message                   
                </div>
                <div class="modal-footer">                    
                    <button type="button" class="BtnOk btn btn-primary" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>
    <div class="modal-backdrop fade show"></div>
    ''';
    var root = html.DivElement();
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
    if (subMessage != null) {
      var btnEle = html.DivElement();
      btnEle.attributes['style'] =
          'padding-top:15px;padding-bottom:5px;cursor: pointer;';
      var t =
          '<label class="text-muted" style="cursor: pointer;">$detailLabel  </label> <a class="list-icons-item dropdown-toggle" data-toggle="dropdown" ></a>';
      // ignore: unsafe_html
      btnEle.setInnerHtml(t, treeSanitizer: html.NodeTreeSanitizer.trusted);
      root.querySelector('.modal-body')?.append(btnEle);

      var container = html.DivElement();
      container.classes.add('modal-detail');
      root.querySelector('.modal-body')?.append(container);

      btnEle.onClick.listen((e) {
        var el = e.target as html.HtmlElement;
        if (el
                .closest('.modal-body')
                ?.querySelector('.modal-detail')
                ?.style
                .display ==
            'none') {
          el
              .closest('.modal-body')
              ?.querySelector('.modal-detail')
              ?.style
              .display = 'block';
        } else {
          el
              .closest('.modal-body')
              ?.querySelector('.modal-detail')
              ?.style
              .display = 'none';
        }
      });

      container.style.overflow = 'hidden';
      container.style.display = 'none';
      container.innerHtml = subMessage;
    }
    root.querySelector('button.BtnOk')?.onClick.listen((e) {
      if (okAction != null) {
        okAction();
      }
      root.remove();
    });

    Future.delayed(Duration(milliseconds: 40), () {
      // print('showAlert focus');
      root.querySelector('.modal')?.focus();
    });
  }

  static Future<bool> showConfirm(String message,
      {String? subMessage,
      String title = 'Confirmar',
      String cancelButtonText = 'Cancelar',
      Function? cancelAction,
      String confirmButtonText = 'Sim',
      Function? confirmAction,
      DialogColor dialogColor = DialogColor.DANGER}) {
    // var uuid = Uuid();
    // final idModal = uuid.v1();
    final comp = Completer<bool>();
    final template = '''
      <div class="modal fade show" tabindex="-1" role="dialog" style="padding-left: 0px; display: block;overflow: auto;" aria-modal="true" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">                
                <div class="modal-header bg-${getColor(dialogColor)} text-white border-0">
                  <h6 class="modal-title">$title</h6>
                  <!--<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>-->
							  </div>
                <div class="modal-body">
                    $message
                    ${subMessage != null ? '<div class="mt-2 text-muted">$subMessage</div>' : ''}                   
                </div>
                <div class="modal-footer"> 
                  <button data-bb-handler="cancel" type="button" class="BtnCancel btn btn-primary">$cancelButtonText</button>
                  <button data-bb-handler="confirm" type="button" class="BtnOk btn btn-danger">$confirmButtonText</button>
               </div>
            </div>
        </div>
    </div>
    <div class="modal-backdrop fade show"></div>
    ''';
    final root = html.DivElement();
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
    root.querySelector('button.BtnCancel')?.onClick.listen((e) {
      if (cancelAction != null) {
        cancelAction();
      }
      root.remove();
      comp.complete(false);
    });
    root.querySelector('button.BtnOk')?.onClick.listen((e) {
      if (confirmAction != null) {
        confirmAction();
      }
      root.remove();
      comp.complete(true);
    });

    Future.delayed(Duration(milliseconds: 40), () {
      root.querySelector('.modal')?.focus();
    });

    return comp.future;
  }
}
