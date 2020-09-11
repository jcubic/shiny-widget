(function() {
  var dataSelector = new Shiny.InputBinding();
  $.extend(dataSelector, {
    find: function(scope) {
      return $(scope).find('.row-grid-control');
    },
    getValue: function(el) {
      return $(el).find('.grid-control-pair').map(function() {
        var self = $(this);
        var result = {
          comparison: {},
          reference: {}
        };
        ['comparison', 'reference'].forEach(function(prop) {
          self.find('.' + prop + '-column').each(function() {
            var self = $(this);
            var name = self.data('name');
            result[prop][name] = self.find('select').val();
          });
        });
        return result;
      }).get();
    },
    setValue: function(el, value) {
      // TODO:
    },
    initialize: initialize,
    subscribe: function(el, callback) {
      console.log('subscribe');
      // change event is broken with selectize it fire only once, we use onChange
      // that trigger custom event update, to ensure that each change will trigger
      // the event. see: https://stackoverflow.com/a/41557815
      $(el).on("update.grid-control", callback);
    },
    unsubscribe: function(el) {
      console.log('unsubscribe');
      $(el).off(".grid-control");
    }
  });

  Shiny.inputBindings.register(dataSelector);

  // ---------------------------------------------------------------------------
  function initialize(el) {
    $(el).find('select:not(.selectized)').each(function() {
      initSelect(this);
    });
    $(el).on('change', function() {
      console.log('change');
    });
  }


  // ---------------------------------------------------------------------------
  function initSelect(select) {
    select = $(select);
    // remove garbage
    var wrapper = select.closest('.select-component');
    var selectized = wrapper.find('select.selectized');
    if (selectized.length) {
      selectized.remove();
      wrapper.find('.selectize-control').remove();
    }
    select.hide().clone().appendTo(wrapper).selectize({
      create: false,
      copyClassesToDropdown: false,
      onChange: function() {
        console.log('onChange');
        $(this).closest('.row-grid-control').trigger('update');
      }
    });
  }

  // ---------------------------------------------------------------------------
  function css_var(el, name, value) {
    el[0].style.setProperty(name, value);
  }
  var doc = $(document);
  // ---------------------------------------------------------------------------
  // validation
  doc.on('change', '.row-grid-control', function() {
    var self = $(this);
    var duplicated_pair = false;
    var lists = [];
    var pairs = self.find('.grid-control-pair').each(function() {
      var pair = $(this);
      var selects = pair.find('select');
      var len = selects.length;
      var left = selects.slice(0, len/2).get();
      var right = selects.slice(len/2, len).get();
      var same = left.every(function(_, i) {
        return left[i].value === right[i].value;
      });
      lists.push({
        str: selects.get().map(function(x) { return x.value; }).join(','),
        pair: pair
      });
      if (same) {
        duplicated_pair = true;
      }
      pair.toggleClass('duplication-error', same);
    });
    pairs.removeClass('duplication-pair-error');
    if (!duplicated_pair && pairs.length > 1) {
      for (var i=lists.length; i--;) {
        for (var j=lists.length; j--;) {
          if (lists[i].str === lists[j].str) {
            $(lists[i].pair, lists[j].pair).addClass('duplication-pair-error');
          }
        }
      }
    }
  });
  // ---------------------------------------------------------------------------
  doc.on('click', '.row-grid-control .remove-pair', function() {
    var self = $(this).closest('li').fadeOut(400, function() {
      self.remove();
    });
    return false;
  });
  // ---------------------------------------------------------------------------
  doc.on('click', '.row-grid-control .add', function() {
    var ul = $(this).closest('.row-grid-control').find('> ul');
    var children = ul.children();
    var li = children.eq(0).clone();
    li.find('.error-message').eq(0).remove();
    li.appendTo(ul);
    initialize(li);
  });
})();
