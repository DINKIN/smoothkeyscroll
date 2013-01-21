$ ->
    updatePx = (element, value) -> element.next().text(value + 'px / frame')

    # Update user interface with existing option values
    if chrome.storage
        chrome.storage.local.get(null, (options) ->
            for option, value of options
                slider = $('#' + option)
                slider.val(value)
                updatePx(slider, value)
        )

    # Save option values as soon as the user changes them
    $('.slider').change ->
        slider = $(this)
        id = slider.attr('id')
        value = slider.val()
        updatePx(slider, value)
        if chrome.storage
            option = {}
            option[id] = value
            chrome.storage.local.set(option)
        else
            window.SmoothKeyScrollSpeeds[id] = value