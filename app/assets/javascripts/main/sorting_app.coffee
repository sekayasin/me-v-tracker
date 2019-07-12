class Sorting.App
  sort: (dataToSort, orderBy, sortField) =>
    sortedData = dataToSort.sort (firstElement, secondElement) ->
      if firstElement[sortField] and Array.isArray firstElement[sortField]
        firstElement = firstElement[sortField][0].name.toLowerCase()
        secondElement = secondElement[sortField][0].name.toLowerCase()

      else if typeof firstElement[sortField] == 'string'
        firstElement = firstElement[sortField].toLowerCase()
        secondElement = secondElement[sortField].toLowerCase()

      else
        firstElement = firstElement.name.toLowerCase()
        secondElement = secondElement.name.toLowerCase()

      order = if firstElement > secondElement then 1 else -1
      orderBy * order

    return sortedData
