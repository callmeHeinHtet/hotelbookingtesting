/// Callback for date selection events
typedef DateSelectionCallback = void Function(DateTime selectedDate);

/// Callback for counter value changes
typedef CounterCallback = void Function(int newValue);

/// Callback for general value changes
typedef ValueChanged<T> = void Function(T value);

/// Callback for async operations that may fail
typedef AsyncCallback = Future<void> Function();

/// Callback for navigation events
typedef NavigationCallback = void Function();

/// Callback for item selection events
typedef ItemSelectionCallback<T> = void Function(T item); 