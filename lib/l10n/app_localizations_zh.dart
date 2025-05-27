// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class StringsZh extends Strings {
  StringsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '像素工房';

  @override
  String get aboutTitle => '关于像素工房';

  @override
  String get welcome => '欢迎使用像素工房！';

  @override
  String get aboutAppDescription =>
      '像素工房是您创作像素艺术的理想工具。无论您是经验丰富的艺术家还是初学者，我们的应用都能为您提供所需的工具，帮助您将像素创意变为现实。';

  @override
  String version(String version) {
    return '版本 $version';
  }

  @override
  String get features =>
      '直观的像素编辑工具\n自定义调色板\n图层支持复杂作品\n动画时间轴创建GIF\n多种格式导出（开发中）\n社区分享功能（开发中）';

  @override
  String get featuresTitle => '主要功能：';

  @override
  String get visitWebsite => '访问我们的网站了解更多：';

  @override
  String get pickAColor => '选择颜色';

  @override
  String get colorPicker => '颜色选择器';

  @override
  String get gotIt => '知道了';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get clear => '清除';

  @override
  String get save => '保存';

  @override
  String get saveAs => '另存为';

  @override
  String get open => '打开';

  @override
  String get export => '导出';

  @override
  String get import => '导入';

  @override
  String get share => '分享';

  @override
  String get close => '关闭';

  @override
  String get projects => '项目';

  @override
  String get lineTool => '直线';

  @override
  String get rectangleTool => '矩形';

  @override
  String get circleTool => '圆形';

  @override
  String get about => '关于';

  @override
  String get invalidFileContent => '文件内容无效';

  @override
  String get anErrorOccurred => '发生错误';

  @override
  String get tryAgain => '重试';

  @override
  String get creatingProject => '正在创建项目...';

  @override
  String get openingProject => '正在打开项目...';

  @override
  String get noProjectsFound => '未找到项目';

  @override
  String get createNewProject => '创建新项目';

  @override
  String get rename => '重命名';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get cancel => '取消';

  @override
  String get deleteProject => '删除项目';

  @override
  String get areYouSureWantToDeleteProject => '确定要删除此项目吗？';

  @override
  String get renameProject => '重命名项目';

  @override
  String get projectName => '项目名称';

  @override
  String timeAgo(String time) {
    return '$time前';
  }

  @override
  String get justNow => '刚刚';

  @override
  String get animationPreview => '动画预览';

  @override
  String get colorPalette => '调色板';

  @override
  String get currentColor => '当前颜色';

  @override
  String get add => '添加';

  @override
  String get layers => '图层';

  @override
  String get deleteLayer => '删除图层';

  @override
  String get areYouSureWantToDeleteLayer => '确定要删除此图层吗？';

  @override
  String get newProject => '新建项目';

  @override
  String get template => '模板';

  @override
  String get width => '宽度';

  @override
  String get height => '高度';

  @override
  String get create => '创建';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get fileMenu => 'File';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete Account';
}
