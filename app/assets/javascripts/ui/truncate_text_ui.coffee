class TruncateText.UI

  generateContent: (text, maximumLength = 100) =>
    return $("<span></span>").text("N/A") unless text
    @maximumLength = maximumLength
    content = $("<p></p>").addClass("expand-text")
    contentText = $("<span></span>")
    content.append(contentText)
    if text.length <= maximumLength
      contentText.text(text)
      return content
    contentText.text("#{text.substr(0, maximumLength)}...")
    showMore = $("<a></a>").addClass("show-more-link").text("Show more")
    showMore.attr("text", text)
    showMore.attr("action", "more")
    content.append(showMore)
    return content

  activateShowMore: =>
    showMoreLinks = $(".show-more-link")
    showMoreLinks.on('click', (event) =>
      link = $(event.currentTarget)
      full = link.attr('text')
      if link.attr("action") is "more"
        link.prev().text(full)
        link.text(" Show less")
        link.attr("action", null)
      else
        texts = "#{full.substr(0, @maximumLength)}..."
        link.prev().text(texts)
        link.text(" Show more")
        link.attr("action", "more")
    )

