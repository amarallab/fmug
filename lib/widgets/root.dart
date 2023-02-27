import 'package:flutter/material.dart';

import 'filtering/filtering.dart';
import '/widgets/gene_selector/gene_selector.dart';
import '/widgets/welcome/welcome.dart';

class Root extends StatefulWidget {
  const Root({super.key});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  int _selectedIndex = 0;

  Widget bodyAtIndex(int index) {
    switch (index) {
      case 0:
        return Welcome(onGeneSelectionTapped: () {
          setState(() {
            _selectedIndex = 1;
          });
        });
      case 1:
        return GeneSelector(onApplyFilterTapped: () {
          setState(() {
            _selectedIndex = 2;
          });
        });
      case 2:
        return const Filtering();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: bodyAtIndex(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
            // type: BottomNavigationBarType.shifting,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: 'Welcome',
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.manage_search),
                label: 'Genes',
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.tune),
                label: 'Filtering',
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            }));
  }
}
