class SearchManager {
  bool isSearchActive = false;
  bool blockAutoRefresh = false;

  void beginSearch(String? keyword) {
    isSearchActive = keyword != null && keyword.isNotEmpty;
    blockAutoRefresh = isSearchActive;
  }

  void cancelSearch() {
    isSearchActive = false;
    blockAutoRefresh = false;
  }
}
