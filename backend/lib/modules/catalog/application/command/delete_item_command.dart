class DeleteItemCommand {
  const DeleteItemCommand({
    required this.itemId,
    required this.requestingUserId,
  });

  final String itemId;
  final String requestingUserId;
}
