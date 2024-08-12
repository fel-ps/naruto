import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teste/models/models_api/model_character.dart';

abstract class IGroup {
  Future<List<Character>> getGrupo(int index , {int page = 1, int limit = 45});
}


class GrupoRepository implements IGroup {
  //os grupos que serão carregados 
  final Map<int, String> groupUrls = {
    0: 'https://narutodb.xyz/api/akatsuki',
    1: 'https://narutodb.xyz/api/tailed-beast',
    2: 'https://narutodb.xyz/api/kara',
  };

  @override
  Future<List<Character>> getGrupo(int index, {int page = 1, int limit = 45}) async {
    final url = groupUrls[index];
    if (url == null) {
      throw Exception('Índice de grupo inválido');
    }

    final requestUrl = '$url?page=$page&limit=$limit';

    try {
      final response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        final dynamic jsonBody = jsonDecode(response.body);
        List<dynamic> grupoList;

        switch (index) {
          case 0:
            grupoList = jsonBody['akatsuki'] ?? [];
            break;
          case 1:
            grupoList = jsonBody['tailedBeasts'] ?? [];
            break;
          case 2:
            grupoList = jsonBody['kara'] ?? [];
            break;
          default:
            throw Exception('Índice de grupo inválido');
        }

        List<Character> personagens = grupoList
            .where((json) =>
                json['images'] != null &&
                json['images'].isNotEmpty &&
                json['jutsu'] != null &&
                json['jutsu'].isNotEmpty &&
                json['debut'] != null &&
                (json['debut']['anime'] != null || json['debut']['manga'] != null))
            .map((json) => Character.fromJson(json))
            .toList();

        return personagens;
      } else if (response.statusCode == 404) {
        throw Exception('Grupo não encontrado');
      } else {
        throw Exception('Erro ao buscar personagens: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
      throw e;
    }
  }
}