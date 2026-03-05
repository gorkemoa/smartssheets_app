class UpdateResultNotesRequestModel {
  final String? resultNotes;

  const UpdateResultNotesRequestModel({
    this.resultNotes,
  });

  Map<String, dynamic> toJson() {
    return {
      'result_notes': resultNotes,
    };
  }
}
