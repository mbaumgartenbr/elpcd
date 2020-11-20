part of 'compose_bloc.dart';

abstract class ComposeEvent extends Equatable {
  const ComposeEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ComposeStarted extends ComposeEvent {
  const ComposeStarted({this.classe});

  final Classe classe;

  @override
  List<Object> get props => [classe];
}

class NameChanged extends ComposeEvent {
  const NameChanged({@required this.name});

  final String name;

  @override
  List<Object> get props => [name];
}

class CodeChanged extends ComposeEvent {
  const CodeChanged({@required this.code});

  final String code;

  @override
  List<Object> get props => [code];
}

class SavePressed extends ComposeEvent {
  const SavePressed({@required this.metadados});

  final List<Metadado> metadados;

  @override
  List<Object> get props => [metadados];
}
