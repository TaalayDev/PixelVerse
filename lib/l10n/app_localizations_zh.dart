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
      '直观的像素编辑工具\n自定义调色板\n图层支持复杂作品\n动画时间轴创建GIF\n多种格式导出\n社区分享功能';

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

  @override
  String get feedback_title => '反馈';

  @override
  String get feedback_thank_you => '感谢您的反馈！';

  @override
  String get feedback_thank_you_message => '您的意见对我们非常重要，将帮助我们改进应用。';

  @override
  String get feedback_return => '返回';

  @override
  String get feedback_help_us => '帮助我们做得更好';

  @override
  String get feedback_intro => '您的意见对项目发展非常重要。请回答几个问题。';

  @override
  String feedback_answered(int count, int total) {
    return '已回答：$count/$total';
  }

  @override
  String get feedback_required => '必填';

  @override
  String get feedback_sending => '发送中...';

  @override
  String get feedback_send => '发送';

  @override
  String get feedback_validation_error => '请回答所有必填问题';

  @override
  String get feedback_very_poor => '非常差';

  @override
  String get feedback_excellent => '优秀';

  @override
  String get feedback_yes => '是';

  @override
  String get feedback_no => '否';

  @override
  String get feedback_text_placeholder => '输入您的答案...';

  @override
  String get feedback_q_satisfaction => '您对应用的满意度如何？';

  @override
  String get feedback_q_missing_features => '您觉得缺少哪些功能？';

  @override
  String get feedback_q_missing_features_placeholder => '描述您希望看到的功能...';

  @override
  String get feedback_q_bug_reports => '您是否遇到过任何错误或崩溃？';

  @override
  String get feedback_q_bug_reports_placeholder => '描述您遇到的问题...';

  @override
  String get feedback_q_price_satisfaction => '您对目前的应用价格满意吗？';

  @override
  String get feedback_q_price_feedback => '如果不满意，您认为合理的价格是多少？';

  @override
  String get feedback_q_price_free => '免费';

  @override
  String get feedback_q_price_up_to_5 => '最多\$5';

  @override
  String get feedback_q_price_5_to_10 => '\$5 - \$10';

  @override
  String get feedback_q_price_10_to_20 => '\$10 - \$20';

  @override
  String get feedback_q_price_more_20 => '超过\$20';

  @override
  String get feedback_q_patreon_support => '您会在Patreon上支持该项目吗？';

  @override
  String get feedback_q_patreon_definitely => '是的，一定会';

  @override
  String get feedback_q_patreon_if_exclusive => '可能，如果有独家功能';

  @override
  String get feedback_q_patreon_if_reasonable => '可能，如果价格合理';

  @override
  String get feedback_q_patreon_probably_not => '可能不会';

  @override
  String get feedback_q_patreon_no => '不，不打算';

  @override
  String get feedback_q_patreon_tier => '您对Patreon的哪个支持级别感兴趣？';

  @override
  String get feedback_q_patreon_tier_3 => '\$3/月 - 提前使用功能';

  @override
  String get feedback_q_patreon_tier_5 => '\$5/月 - + 独家主题';

  @override
  String get feedback_q_patreon_tier_10 => '\$10/月 - + 影响开发';

  @override
  String get feedback_q_usage_frequency => '您多久使用一次应用？';

  @override
  String get feedback_q_usage_daily => '每天';

  @override
  String get feedback_q_usage_several_week => '每周几次';

  @override
  String get feedback_q_usage_once_week => '每周一次';

  @override
  String get feedback_q_usage_several_month => '每月几次';

  @override
  String get feedback_q_usage_rarely => '很少';

  @override
  String get feedback_q_main_use_case => '您主要用应用做什么？';

  @override
  String get feedback_q_use_pixel_art => '创作像素艺术';

  @override
  String get feedback_q_use_game_design => '游戏设计';

  @override
  String get feedback_q_use_animation => '动画';

  @override
  String get feedback_q_use_hobby => '爱好/娱乐';

  @override
  String get feedback_q_use_professional => '专业工作';

  @override
  String get feedback_q_use_learning => '学习';

  @override
  String get feedback_q_additional_feedback => '其他评论和建议';

  @override
  String get feedback_q_additional_feedback_placeholder => '分享您对应用的看法...';

  @override
  String get feedback_q_recommend => '您会向朋友推荐这个应用吗？';

  @override
  String get feedback_dialog_title => 'We\'d Love Your Feedback!';

  @override
  String get feedback_dialog_description =>
      'Your opinion matters! Help us make the app better by sharing your thoughts.';

  @override
  String get feedback_dialog_benefit_1 => 'Share ideas for new features';

  @override
  String get feedback_dialog_benefit_2 => 'Report bugs and issues';

  @override
  String get feedback_dialog_benefit_3 => 'Help shape the app\'s future';

  @override
  String get feedback_dialog_leave_feedback => 'Leave Feedback';

  @override
  String get feedback_dialog_maybe_later => 'Maybe Later';

  @override
  String get feedback_dialog_dont_ask => 'Don\'t ask again';
}
