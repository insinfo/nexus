import '../types/models.dart';

enum XYConnectionMode {
  strict,
  loose,
}

typedef XYConnectionValidator = bool Function(FlowConnection connection);

class XYConnectionInProgress {
  const XYConnectionInProgress({
    required this.fromNodeId,
    required this.fromType,
    required this.startPointer,
    required this.pointer,
    this.fromHandleId,
    this.targetNodeId,
    this.targetHandleId,
    this.targetType,
    this.isValid,
    this.connection,
  });

  final String fromNodeId;
  final String? fromHandleId;
  final HandleType fromType;
  final XYPosition startPointer;
  final XYPosition pointer;
  final String? targetNodeId;
  final String? targetHandleId;
  final HandleType? targetType;
  final bool? isValid;
  final FlowConnection? connection;

  XYFinalConnectionState get finalState => XYFinalConnectionState(
        fromNodeId: fromNodeId,
        fromHandleId: fromHandleId,
        fromType: fromType,
        startPointer: startPointer,
        pointer: pointer,
        targetNodeId: targetNodeId,
        targetHandleId: targetHandleId,
        targetType: targetType,
        isValid: isValid,
        connection: connection,
      );
}

class XYFinalConnectionState {
  const XYFinalConnectionState({
    required this.fromNodeId,
    required this.fromType,
    required this.startPointer,
    required this.pointer,
    this.fromHandleId,
    this.targetNodeId,
    this.targetHandleId,
    this.targetType,
    this.isValid,
    this.connection,
  });

  final String fromNodeId;
  final String? fromHandleId;
  final HandleType fromType;
  final XYPosition startPointer;
  final XYPosition pointer;
  final String? targetNodeId;
  final String? targetHandleId;
  final HandleType? targetType;
  final bool? isValid;
  final FlowConnection? connection;
}

class XYHandleState {
  const XYHandleState({
    this.fromNodeId,
    this.fromHandleId,
    this.fromType,
    this.pointer,
    this.startPointer,
    this.targetNodeId,
    this.targetHandleId,
    this.targetType,
    this.isValid,
    this.connection,
  });

  final String? fromNodeId;
  final String? fromHandleId;
  final HandleType? fromType;
  final XYPosition? pointer;
  final XYPosition? startPointer;
  final String? targetNodeId;
  final String? targetHandleId;
  final HandleType? targetType;
  final bool? isValid;
  final FlowConnection? connection;

  bool get inProgress => fromNodeId != null && fromType != null;

  XYConnectionInProgress? get inProgressState {
    final nodeId = fromNodeId;
    final type = fromType;
    final currentPointer = pointer;
    final startedAt = startPointer;
    if (nodeId == null ||
        type == null ||
        currentPointer == null ||
        startedAt == null) {
      return null;
    }

    return XYConnectionInProgress(
      fromNodeId: nodeId,
      fromHandleId: fromHandleId,
      fromType: type,
      startPointer: startedAt,
      pointer: currentPointer,
      targetNodeId: targetNodeId,
      targetHandleId: targetHandleId,
      targetType: targetType,
      isValid: isValid,
      connection: connection,
    );
  }

  XYHandleState copyWith({
    String? fromNodeId,
    String? fromHandleId,
    HandleType? fromType,
    XYPosition? pointer,
    XYPosition? startPointer,
    String? targetNodeId,
    String? targetHandleId,
    HandleType? targetType,
    bool? isValid,
    FlowConnection? connection,
    bool clear = false,
  }) {
    if (clear) {
      return const XYHandleState();
    }

    return XYHandleState(
      fromNodeId: fromNodeId ?? this.fromNodeId,
      fromHandleId: fromHandleId ?? this.fromHandleId,
      fromType: fromType ?? this.fromType,
      pointer: pointer ?? this.pointer,
      startPointer: startPointer ?? this.startPointer,
      targetNodeId: targetNodeId ?? this.targetNodeId,
      targetHandleId: targetHandleId ?? this.targetHandleId,
      targetType: targetType ?? this.targetType,
      isValid: isValid ?? this.isValid,
      connection: connection ?? this.connection,
    );
  }
}

XYHandleState startHandleConnection({
  required String nodeId,
  required HandleType handleType,
  String? handleId,
  required XYPosition pointer,
}) {
  return XYHandleState(
    fromNodeId: nodeId,
    fromHandleId: handleId,
    fromType: handleType,
    pointer: pointer,
    startPointer: pointer,
  );
}

XYHandleState updateHandleConnection(
  XYHandleState state, {
  required XYPosition pointer,
  String? targetNodeId,
  String? targetHandleId,
  HandleType? targetType,
  XYConnectionMode connectionMode = XYConnectionMode.strict,
  XYConnectionValidator? validator,
}) {
  if (!state.inProgress) {
    return state;
  }

  FlowConnection? connection;
  bool? isValid;

  if (targetNodeId != null && targetType != null) {
    connection = completeHandleConnection(
      state: state,
      targetNodeId: targetNodeId,
      targetHandleId: targetHandleId,
      targetType: targetType,
      connectionMode: connectionMode,
      validator: validator,
    );
    isValid = connection != null;
  }

  return state.copyWith(
    pointer: pointer,
    targetNodeId: targetNodeId,
    targetHandleId: targetHandleId,
    targetType: targetType,
    isValid: isValid,
    connection: connection,
  );
}

bool canConnectHandles({
  required XYHandleState state,
  required String targetNodeId,
  required HandleType targetType,
  XYConnectionMode connectionMode = XYConnectionMode.strict,
}) {
  if (!state.inProgress) {
    return false;
  }

  if (connectionMode == XYConnectionMode.strict) {
    return state.fromNodeId != targetNodeId && state.fromType != targetType;
  }

  return state.fromNodeId != targetNodeId || state.fromHandleId != null;
}

FlowConnection? completeHandleConnection({
  required XYHandleState state,
  required String targetNodeId,
  String? targetHandleId,
  required HandleType targetType,
  XYConnectionMode connectionMode = XYConnectionMode.strict,
  XYConnectionValidator? validator,
}) {
  if (!canConnectHandles(
    state: state,
    targetNodeId: targetNodeId,
    targetType: targetType,
    connectionMode: connectionMode,
  )) {
    return null;
  }

  final connection = state.fromType == HandleType.source
      ? FlowConnection(
          source: state.fromNodeId!,
          target: targetNodeId,
          sourceHandle: state.fromHandleId,
          targetHandle: targetHandleId,
        )
      : FlowConnection(
          source: targetNodeId,
          target: state.fromNodeId!,
          sourceHandle: targetHandleId,
          targetHandle: state.fromHandleId,
        );

  if (validator != null && !validator(connection)) {
    return null;
  }

  return connection;
}

XYFinalConnectionState? finalizeHandleConnection(XYHandleState state) {
  return state.inProgressState?.finalState;
}

FlowConnection reconnectHandleConnection({
  required FlowEdge edge,
  required bool reconnectSourceHandle,
  required String targetNodeId,
  String? targetHandleId,
}) {
  return FlowConnection(
    source: reconnectSourceHandle ? targetNodeId : edge.source,
    target: reconnectSourceHandle ? edge.target : targetNodeId,
    sourceHandle: reconnectSourceHandle ? targetHandleId : edge.sourceHandle,
    targetHandle: reconnectSourceHandle ? edge.targetHandle : targetHandleId,
  );
}
