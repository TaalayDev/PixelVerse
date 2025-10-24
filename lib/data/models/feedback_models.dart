import 'package:flutter/foundation.dart';

/// Типы вопросов в опроснике
enum QuestionType {
  rating, // Оценка от 1 до 5
  multiChoice, // Множественный выбор
  singleChoice, // Единичный выбор
  textInput, // Текстовое поле
  yesNo, // Да/Нет
}

/// Модель вопроса
class FeedbackQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String>? options; // Для выборочных вопросов
  final bool isRequired;
  final String? placeholder; // Для текстовых полей

  const FeedbackQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options,
    this.isRequired = false,
    this.placeholder,
  });
}

/// Модель ответа
class FeedbackAnswer {
  final String questionId;
  final dynamic value; // Может быть String, int, List<String>, bool

  const FeedbackAnswer({
    required this.questionId,
    required this.value,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'value': value,
      };
}

/// Состояние опросника
@immutable
class FeedbackState {
  final Map<String, dynamic> answers;
  final bool isSubmitted;
  final bool isSubmitting;
  final String? errorMessage;

  const FeedbackState({
    this.answers = const {},
    this.isSubmitted = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  FeedbackState copyWith({
    Map<String, dynamic>? answers,
    bool? isSubmitted,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return FeedbackState(
      answers: answers ?? this.answers,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool isQuestionAnswered(String questionId) {
    return answers.containsKey(questionId) && answers[questionId] != null;
  }

  dynamic getAnswer(String questionId) {
    return answers[questionId];
  }
}
