import 'package:flutter/material.dart';


class CustomSearchBar extends StatefulWidget {
  // função que devolve o texto para a Home
  final Function(String) onSearch;

  CustomSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _pesquisa = TextEditingController();
  bool _showClearIcon = false; 

  // função que pega o texto atual e manda para a Home
  void _submitSearch() {
    widget.onSearch(_pesquisa.text.trim());
  }

  // função para limpar
  void _clearSearch() {
    _pesquisa.clear();
    setState(() {
      _showClearIcon = false;
    });
    widget.onSearch(''); // reseta a lista na Home
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      
      child: TextField(
        controller: _pesquisa,
        // mostra ícone de X sempre que digita algo
        onChanged: (value) {
          setState(() {
            _showClearIcon = value.isNotEmpty;
          });
        },
        textInputAction: TextInputAction.search, // muda o botão do teclado do celular para uma "lupa" ou "buscar"
        onSubmitted: (_) => _submitSearch(), // "Enter" no teclado
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: 'Busque um título',
          hintStyle: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(left: 16),
          
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min, // ocupa o menor espaço possível
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (_showClearIcon)
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  icon: Icon(Icons.close, color: Colors.grey, size: 20),
                  onPressed: _clearSearch,
                ),
              IconButton(
                padding: EdgeInsets.symmetric(horizontal: 12),
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: _submitSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}