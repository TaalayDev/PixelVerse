// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class StringsRu extends Strings {
  StringsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'PixelVerse';

  @override
  String get aboutTitle => 'О программе PixelVerse';

  @override
  String get welcome => 'Добро пожаловать в PixelVerse!';

  @override
  String get aboutAppDescription =>
      'PixelVerse - это ваш путь к созданию потрясающего пиксельного искусства. Независимо от того, являетесь ли вы опытным художником или только начинаете, наше приложение предоставляет все необходимые инструменты для воплощения ваших пиксельных идей в жизнь.';

  @override
  String version(String version) {
    return 'Версия $version';
  }

  @override
  String get features =>
      'Интуитивные инструменты для редактирования пикселей, \nПользовательские цветовые палитры, \nПоддержка слоев для сложных работ, \nВременная шкала анимации для создания GIF, \nЭкспорт в различных форматах (в разработке), \nОбмен работами в сообществе (в разработке)';

  @override
  String get featuresTitle => 'Основные возможности:';

  @override
  String get visitWebsite =>
      'Посетите мой сайт для получения дополнительной информации:';

  @override
  String get pickAColor => 'Выберите цвет';

  @override
  String get colorPicker => 'Выбор цвета';

  @override
  String get gotIt => 'Понятно';

  @override
  String get undo => 'Отменить';

  @override
  String get redo => 'Повторить';

  @override
  String get clear => 'Очистить';

  @override
  String get save => 'Сохранить';

  @override
  String get saveAs => 'Сохранить как';

  @override
  String get open => 'Открыть';

  @override
  String get export => 'Экспорт';

  @override
  String get import => 'Импорт';

  @override
  String get share => 'Поделиться';

  @override
  String get close => 'Закрыть';

  @override
  String get projects => 'Проекты';

  @override
  String get lineTool => 'Линия';

  @override
  String get rectangleTool => 'Прямоугольник';

  @override
  String get circleTool => 'Круг';

  @override
  String get about => 'О программе';

  @override
  String get invalidFileContent => 'Неверное содержимое файла';

  @override
  String get anErrorOccurred => 'Произошла ошибка';

  @override
  String get tryAgain => 'Попробовать снова';

  @override
  String get creatingProject => 'Создание проекта...';

  @override
  String get openingProject => 'Открытие проекта...';

  @override
  String get noProjectsFound => 'Проекты не найдены';

  @override
  String get createNewProject => 'Создать новый';

  @override
  String get rename => 'Переименовать';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get cancel => 'Отмена';

  @override
  String get deleteProject => 'Удалить проект';

  @override
  String get areYouSureWantToDeleteProject =>
      'Вы уверены, что хотите удалить этот проект?';

  @override
  String get renameProject => 'Переименовать проект';

  @override
  String get projectName => 'Название проекта';

  @override
  String timeAgo(String time) {
    return '$time назад';
  }

  @override
  String get justNow => 'Только что';

  @override
  String get animationPreview => 'Предпросмотр анимации';

  @override
  String get colorPalette => 'Цветовая палитра';

  @override
  String get currentColor => 'Текущий цвет';

  @override
  String get add => 'Добавить';

  @override
  String get layers => 'Слои';

  @override
  String get deleteLayer => 'Удалить слой';

  @override
  String get areYouSureWantToDeleteLayer =>
      'Вы уверены, что хотите удалить этот слой?';

  @override
  String get newProject => 'Новый проект';

  @override
  String get template => 'Шаблон';

  @override
  String get width => 'Ширина';

  @override
  String get height => 'Высота';

  @override
  String get create => 'Создать';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get fileMenu => 'File';
}
