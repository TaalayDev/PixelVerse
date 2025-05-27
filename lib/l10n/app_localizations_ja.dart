// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class StringsJa extends Strings {
  StringsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ピクセルバース';

  @override
  String get aboutTitle => 'ピクセルバースについて';

  @override
  String get welcome => 'ピクセルバースへようこそ！';

  @override
  String get aboutAppDescription =>
      'ピクセルバースは、素晴らしいピクセルアートを作成するためのツールです。経験豊富なアーティストも、初心者も、このアプリケーションを使って、あなたのピクセルアートのビジョンを実現できます。';

  @override
  String version(String version) {
    return 'バージョン $version';
  }

  @override
  String get features =>
      '直感的なピクセル編集ツール\nカスタムカラーパレット\n複雑なアートワークのためのレイヤーサポート\nGIF作成用のアニメーションタイムライン\n様々なフォーマットでのエクスポート（開発中）\nコミュニティでの共有機能（開発中）';

  @override
  String get featuresTitle => '主な機能：';

  @override
  String get visitWebsite => '詳細はウェブサイトをご覧ください：';

  @override
  String get pickAColor => '色を選択';

  @override
  String get colorPicker => 'カラーピッカー';

  @override
  String get gotIt => '了解';

  @override
  String get undo => '元に戻す';

  @override
  String get redo => 'やり直し';

  @override
  String get clear => 'クリア';

  @override
  String get save => '保存';

  @override
  String get saveAs => '名前を付けて保存';

  @override
  String get open => '開く';

  @override
  String get export => 'エクスポート';

  @override
  String get import => 'インポート';

  @override
  String get share => '共有';

  @override
  String get close => '閉じる';

  @override
  String get projects => 'プロジェクト';

  @override
  String get lineTool => '直線';

  @override
  String get rectangleTool => '四角形';

  @override
  String get circleTool => '円';

  @override
  String get about => '概要';

  @override
  String get invalidFileContent => '無効なファイル内容';

  @override
  String get anErrorOccurred => 'エラーが発生しました';

  @override
  String get tryAgain => '再試行';

  @override
  String get creatingProject => 'プロジェクトを作成中...';

  @override
  String get openingProject => 'プロジェクトを開いています...';

  @override
  String get noProjectsFound => 'プロジェクトが見つかりません';

  @override
  String get createNewProject => '新規作成';

  @override
  String get rename => '名前の変更';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get cancel => 'キャンセル';

  @override
  String get deleteProject => 'プロジェクトの削除';

  @override
  String get areYouSureWantToDeleteProject => 'このプロジェクトを削除してもよろしいですか？';

  @override
  String get renameProject => 'プロジェクト名の変更';

  @override
  String get projectName => 'プロジェクト名';

  @override
  String timeAgo(String time) {
    return '$time前';
  }

  @override
  String get justNow => 'たった今';

  @override
  String get animationPreview => 'アニメーションプレビュー';

  @override
  String get colorPalette => 'カラーパレット';

  @override
  String get currentColor => '現在の色';

  @override
  String get add => '追加';

  @override
  String get layers => 'レイヤー';

  @override
  String get deleteLayer => 'レイヤーを削除';

  @override
  String get areYouSureWantToDeleteLayer => 'このレイヤーを削除してもよろしいですか？';

  @override
  String get newProject => '新規プロジェクト';

  @override
  String get template => 'テンプレート';

  @override
  String get width => '幅';

  @override
  String get height => '高さ';

  @override
  String get create => '作成';

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
