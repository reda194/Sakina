// Import to access types in this file
import 'therapy_program_model.dart' as therapy;

// Re-export therapy-related models and types from therapy_program_model.dart
export 'therapy_program_model.dart' show
  ExerciseType,
  ExerciseDifficulty,
  TherapyExerciseModel;

// Alias for backwards compatibility
typedef ExerciseModel = therapy.TherapyExerciseModel;
