class Helpers.UI
  getValueById: (id) ->
    return $(id).val()

  sortHash: (targetHash) ->
    result = {}
    keys = Object.keys(targetHash).sort (a, b) -> targetHash[b] - targetHash[a]
    for key in keys
      result[key] = targetHash[key]
    return result

  objectToArray: (obj) ->
    Object.values(obj)

  capitalizeSurvey: (words) ->
    (words.split(' ').map (word) ->
      word[0].toUpperCase() + word[1..-1].toLowerCase()).join ' '

  truncateTitle: (words) ->
    if words.length > 12
      words = words.substring(0, 12) + "..."
    words
