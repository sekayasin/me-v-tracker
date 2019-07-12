class Export.UI
  prepareExport: (chartIds, reportName, loader) ->
    loader.show()
    lastIndex = chartIds.length - 1
    zip = new JSZip()
    report = zip.folder(reportName)
    return [loader, lastIndex, report, zip]

  getJPGExport: (chartIds, reportName, loader) ->
    [loader, lastIndex, report, zip] = @prepareExport(chartIds, reportName, loader)
    for chartId, index in chartIds
      do (chartId, index) ->
        element = document.getElementById(chartId)
        html2canvas(element, {
          scale: 5
          onrendered: (canvas) ->
            imgDataURL = canvas.toDataURL('image/png').split(";")[1].split(",")[1]
            report.file("#{chartId}.jpg", imgDataURL, {base64: true})
            if index == lastIndex
              zip.generateAsync(type: 'blob').then (content) ->
                saveAs content, "#{reportName}_jpg.zip"
                loader.hide()
                return
      })

  getPdfExport: (chartIds, reportName, loader) ->
    [loader, lastIndex, report, zip] = @prepareExport(chartIds, reportName, loader)
    for chartId, index in chartIds
      do (chartId, index) ->
        temp_canvas = document.getElementById(chartId)
        html2canvas(temp_canvas, {
          scale: 5,
          onrendered: (canvas) ->
            imgDataURL = canvas.toDataURL('image/png')
            pdf = new jsPDF("l", "mm", "a4")
            if index != lastIndex
              pdf.addImage(imgDataURL, 'PNG', 40, 40, 110, 70)
              report.file("#{chartId}.pdf", pdf.output(), {binary: true})
            else
              pdf.addImage(imgDataURL, 'PNG', 30, 15, 200, 190)
              report.file("#{chartId}.pdf", pdf.output(), {binary: true})
              zip.generateAsync(type: 'blob').then (content) ->
                saveAs content, "#{reportName}_pdf.zip"
                loader.hide()
                return
        })
