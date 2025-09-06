import 'package:flutter/material.dart';
import '../../../../core/constants/color_palette.dart';
import '../../../../core/utils/backend_api_manager.dart';
import '../../../../core/components/bottom_navigation_component.dart';
import '../../../../core/navigation/navigation_controller.dart';
import '../../../settings/presentation/pages/configuration_page.dart';
import 'my_newsletters_screen.dart';

class ChannelsScreen extends StatefulWidget {
  const ChannelsScreen({super.key});

  @override
  State<ChannelsScreen> createState() => _ChannelsScreenState();
}

class _ChannelsScreenState extends State<ChannelsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allChannels = [];
  List<Map<String, dynamic>> _filteredChannels = [];
  Set<String> _followedChannels = {};
  bool _isLoading = true;
  bool _isSearchExpanded = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await BackendApiManager.getSources();
      final List<dynamic> sources = response['sources'] ?? [];
      
      setState(() {
        _allChannels = sources.map((source) => {
          'id': source['id'],
          'name': source['name'],
          'icon': Icons.newspaper,
          'category': source['category'] ?? 'geral',
          'country': source['country'] ?? 'br',
        }).toList();
        _filteredChannels = List.from(_allChannels);
        _isLoading = false;
      });

      // Load user's followed channels (you might want to get this from user preferences)
      await _loadFollowedChannels();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao carregar canais: $e';
        _isLoading = false;
        // Fallback to static data
        _allChannels = [
          {'id': 'uol', 'name': 'UOL', 'icon': Icons.newspaper, 'category': 'geral'},
          {'id': 'globo', 'name': 'Globo', 'icon': Icons.newspaper, 'category': 'geral'},
          {'id': 'terra', 'name': 'Terra', 'icon': Icons.newspaper, 'category': 'tecnologia'},
          {'id': 'metropoles', 'name': 'Metropoles', 'icon': Icons.newspaper, 'category': 'geral'},
        ];
        _filteredChannels = List.from(_allChannels);
      });
    }
  }

  Future<void> _loadFollowedChannels() async {
    final response = await BackendApiManager.getCurrentUser();
    final List<String> followedChannels = (response['user']['followed_channels'] ?? []).cast<String>();

    setState(() {
      _followedChannels = followedChannels.toSet();
    });
  }

  void _filterChannels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChannels = List.from(_allChannels);
      } else {
        _filteredChannels = _allChannels
            .where((channel) =>
                channel['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleFollow(String channelId) {
    setState(() {
      if (_followedChannels.contains(channelId)) {
        _followedChannels.remove(channelId);
      } else {
        _followedChannels.add(channelId);
      }
    });
    
    _saveFollowedChannels();
  }

  Future<void> _saveFollowedChannels() async {
    print('Saving followed channels: $_followedChannels');
    final response = BackendApiManager.updateProfile(followedChannels: _followedChannels.toList());

    print(response);
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        _filterChannels('');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _filterChannels,
                decoration: const InputDecoration(
                  hintText: 'Procurar canais...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: AppColors.textMedium),
                ),
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                ),
              )
            : const Text(
                'Canais de Notícias',
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _isSearchExpanded ? Icons.close : Icons.search,
              color: AppColors.textDark,
            ),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Column(
                children: [
                  if (_errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  Expanded(
                    child: _filteredChannels.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhum canal encontrado',
                              style: TextStyle(
                                color: AppColors.textMedium,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredChannels.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.8,
                            ),
                            itemBuilder: (context, index) {
                              final channel = _filteredChannels[index];
                              final channelId = channel['id'].toString();
                              final isFollowed = _followedChannels.contains(channelId);

                              return GestureDetector(
                                onTap: () => _toggleFollow(channelId),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isFollowed ? AppColors.primary : AppColors.border,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        channel['icon'],
                                        size: 36,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        channel['name'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.textDark,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isFollowed ? AppColors.primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.primary, width: 1),
                                        ),
                                        child: Text(
                                          isFollowed ? 'Seguindo' : 'Seguir',
                                          style: TextStyle(
                                            color: isFollowed ? Colors.white : AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: BottomNavigationComponent(
        forcePage: BottomNavPage.channels,
      ),
    );
  }
}
