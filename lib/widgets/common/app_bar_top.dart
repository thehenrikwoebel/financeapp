import 'package:flutter/material.dart';
import 'package:frontend/services/app_strings.dart';

class AppBarTop extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onRefresh;
  final ValueChanged<String>? onSearch;
  final bool showSearch;
  final bool isSelectionMode;
  final int selectedCount;
  final VoidCallback? onExitSelectionMode;
  final VoidCallback? onDeleteSelected;
  final bool isSearching;
  final ValueChanged<bool>? onSearchToggle;

  const AppBarTop({
    super.key,
    this.onRefresh,
    this.onSearch,
    this.showSearch = true,
    this.isSelectionMode = false,
    this.selectedCount = 0,
    this.onExitSelectionMode,
    this.onDeleteSelected,
    required this.isSearching,
    this.onSearchToggle,
  });

  @override
  State<AppBarTop> createState() => _AppBarTopState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarTopState extends State<AppBarTop> {
  bool _isSearching = false;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _toggleSearch() {
    widget.onSearchToggle?.call(!widget.isSearching);
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        Future.microtask(() => _focusNode.requestFocus());
      } else {
        _focusNode.unfocus();
        _controller.clear();
        widget.onSearch?.call("");
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStrings(),
      builder: (context, _) {
        // selection mode AppBar
        if (widget.isSelectionMode) {
          return AppBar(
            backgroundColor: Colors.blue,
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onExitSelectionMode,
            ),
            title: Text(
              '${widget.selectedCount} ${AppStrings.get('selected')}',
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: widget.onDeleteSelected,
              ),
            ],
          );
        }

        // normal / search AppBar
        return AppBar(
          backgroundColor: Colors.blue,
          title: _isSearching
              ? TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: AppStrings.get('search'),
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => widget.onSearch?.call(value),
                )
              : Text(AppStrings.get('title')),
          actions: [
            if (widget.showSearch)
              IconButton(
                onPressed: _toggleSearch,
                icon: Icon(_isSearching ? Icons.close : Icons.search),
              ),
            Visibility(
              visible: !_isSearching,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.replay_outlined),
              ),
            ),
          ],
        );
      },
    );
  }
}
