import 'package:logger/logger.dart';

import '../main.dart';

class TranslatorService {
  var logger = Logger();
  Future<List<dynamic>> getTranslatorAvailable() async {
    final data = await supabase.from('word_translator').select('*');

    return data as List<dynamic>;
  }

  Future<List<dynamic>> getSurigaononList() async {
    final data = await supabase.from('suriganon_list').select('word');

    return data as List<dynamic>;
  }

  Future<List<dynamic>> getContributeWord() async {
    final data = await supabase.from('contributes_word').select('*');

    return data as List<dynamic>;
  }

  Future<bool> getUserAccount(String username, String password) async {
    final data = await supabase
        .from('admin_account')
        .select('*')
        .eq('username', username)
        .eq('code', password);

    if (data.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> getContributorList(
      String wordTranslated, int lang, String wordSuriganon) async {
    final data = await supabase
        .from('contributes_word')
        .select('*')
        .eq('suriganon_word', wordSuriganon)
        .eq('language', lang)
        .eq('translated_word', wordTranslated);

    final wordListed = await supabase
        .from('word_translator')
        .select('*')
        .eq('suriganon', wordSuriganon)
        .eq('language', lang)
        .eq('translated_word', wordTranslated);

    if (data.isEmpty && wordListed.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> validateSuriganonList(String contribute) async {
    final data = await supabase
        .from('contributes_word')
        .select('suriganon_word')
        .eq('suriganon_word', contribute);

    final getMasterList = await supabase
        .from('suriganon_list')
        .select('word')
        .eq('word', contribute);

    if (data.isEmpty && getMasterList.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void createContributes(
      String suriganonWords, int lang, String translated) async {
    await supabase.from('contributes_word').insert({
      'suriganon_word': suriganonWords,
      'language': lang,
      'translated_word': translated,
      'status': 0
    });
  }

  Future<void> deleteContribution(id) async {
    await supabase
        .from('contributes_word')
        .delete()
        .match({'contribute_id': id});
  }

  Future<void> deleteAllContribution() async {
    await supabase.from('contributes_word').delete().neq('contribute_id', 0);
  }

  Future<void> aprovalRequest(String suriganonWord, int lang, String translated,
      int contributionId) async {
    final getMasterList = await supabase
        .from('suriganon_list')
        .select('*')
        .eq('word', suriganonWord);

    if (getMasterList.isNotEmpty) {
      var id = getMasterList[0]['id'];
      var resp = await supabase.from('translated_list').insert({
        'suriganonid': id,
        'language': lang,
        'translated_word': translated
      }).select();

      if (resp.length > 0) {
        await supabase
            .from('contributes_word')
            .delete()
            .match({'contribute_id': contributionId});
      } else {
        await supabase
            .from('suriganon_list')
            .delete()
            .match({'id': getMasterList[0]['id']});
      }
    } else {
      var dataRes = await supabase
          .from('suriganon_list')
          .insert({'word': suriganonWord}).select();

      if (dataRes.length > 0) {
        var id = dataRes[0]['id'];
        var resp = await supabase.from('translated_list').insert({
          'suriganonid': id,
          'language': lang,
          'translated_word': translated
        }).select();

        if (resp.length > 0) {
          await supabase
              .from('contributes_word')
              .delete()
              .match({'contribute_id': contributionId});
        } else {
          await supabase
              .from('suriganon_list')
              .delete()
              .match({'id': dataRes[0]['id']});
        }
      }
    }
  }
}
