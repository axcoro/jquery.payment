assert = require('assert')
window = require('jsdom').jsdom().createWindow()
$      = require('jquery')(window)
global.jQuery = $
global.window = window
global.document = window.document

require('../lib/jquery.payment')

describe 'jquery.payment', ->
  describe 'Validating a card number', ->
    it 'should fail if empty', ->
      topic = $.payment.validateCardNumber ''
      assert.equal topic, false

    it 'should fail if is a bunch of spaces', ->
      topic = $.payment.validateCardNumber '                 '
      assert.equal topic, false

    it 'should success if is valid', ->
      topic = $.payment.validateCardNumber '4242424242424242'
      assert.equal topic, true

    it 'that has dashes in it but is valid', ->
      topic = $.payment.validateCardNumber '4242-4242-4242-4242'
      assert.equal topic, true

    it 'should succeed if it has spaces in it but is valid', ->
      topic = $.payment.validateCardNumber '4242 4242 4242 4242'
      assert.equal topic, true

    it 'that does not pass the luhn checker', ->
      topic = $.payment.validateCardNumber '4242424242424241'
      assert.equal topic, false

    it 'should fail if is more than 16 digits', ->
      topic = $.payment.validateCardNumber '42424242424242424'
      assert.equal topic, false

    it 'should fail if is less than 10 digits', ->
      topic = $.payment.validateCardNumber '424242424'
      assert.equal topic, false

    it 'should fail with non-digits', ->
      topic = $.payment.validateCardNumber '4242424e42424241'
      assert.equal topic, false

    it 'should validate for all card types', ->
      assert($.payment.validateCardNumber('4029174173871700'), 'naranja')
      assert($.payment.validateCardNumber('4029188823230745'), 'naranja')
      assert($.payment.validateCardNumber('5275718605203862'), 'naranja')
      assert($.payment.validateCardNumber('5275720847313376'), 'naranja')
      assert($.payment.validateCardNumber('5895625366531656'), 'naranja')

      assert($.payment.validateCardNumber('5465531782847777'), 'nativa')

      assert($.payment.validateCardNumber('6034880724565165'), 'tarshop')
      assert($.payment.validateCardNumber('2799573107582'), 'tarshop')

      assert($.payment.validateCardNumber('6034937348103201'), 'cencosud')
      
      assert($.payment.validateCardNumber('6271702268025038'), 'cabal')
      assert($.payment.validateCardNumber('5896577655366865'), 'cabal')
      assert($.payment.validateCardNumber('6035221580711081'), 'cabal')
      assert($.payment.validateCardNumber('6042013013318555'), 'cabal')
      assert($.payment.validateCardNumber('6044002445876882'), 'cabal')

      assert($.payment.validateCardNumber('5011051045705026'), 'argencard')

      assert($.payment.validateCardNumber('4111111111111111'), 'visa')
      assert($.payment.validateCardNumber('4012888888881881'), 'visa')
      assert($.payment.validateCardNumber('4462030000000000'), 'visa')
      assert($.payment.validateCardNumber('4484070000000000'), 'visa')

      assert($.payment.validateCardNumber('5555555555554444'), 'master')
      assert($.payment.validateCardNumber('5454545454545454'), 'master')

      assert($.payment.validateCardNumber('378282246310005'), 'amex')
      assert($.payment.validateCardNumber('371449635398431'), 'amex')
      assert($.payment.validateCardNumber('378734493671000'), 'amex')

      assert($.payment.validateCardNumber('36700102000000'), 'diners')
      assert($.payment.validateCardNumber('36148900647913'), 'diners')

      assert($.payment.validateCardNumber('6062822241875177'), 'hipercard')

      assert($.payment.validateCardNumber('6363685624067423'), 'elo')
      assert($.payment.validateCardNumber('4389357440762745'), 'elo')
      assert($.payment.validateCardNumber('5067268104457611'), 'elo')
      assert($.payment.validateCardNumber('4576311327618218'), 'elo')

      assert($.payment.validateCardNumber('5300321316680145'), 'melicard')
      assert($.payment.validateCardNumber('5224991854532800'), 'melicard')

  describe 'Validating a CVC', ->
    it 'should fail if is empty', ->
      topic = $.payment.validateCardCVC ''
      assert.equal topic, false

    it 'should pass if is valid', ->
      topic = $.payment.validateCardCVC '123'
      assert.equal topic, true

    it 'should fail with non-digits', ->
      topic = $.payment.validateCardNumber '12e'
      assert.equal topic, false

    it 'should fail with less than 3 digits', ->
      topic = $.payment.validateCardNumber '12'
      assert.equal topic, false

    it 'should fail with more than 4 digits', ->
      topic = $.payment.validateCardNumber '12345'
      assert.equal topic, false

  describe 'Validating an expiration date', ->
    it 'should fail expires is before the current year', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear() - 1
      assert.equal topic, false

    it 'that expires in the current year but before current month', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth(), currentTime.getFullYear()
      assert.equal topic, false

    it 'that has an invalid month', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry 13, currentTime.getFullYear()
      assert.equal topic, false

    it 'that is this year and month', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear()
      assert.equal topic, true

    it 'that is just after this month', ->
      # Remember - months start with 0 in JavaScript!
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear()
      assert.equal topic, true

    it 'that is after this year', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, currentTime.getFullYear() + 1
      assert.equal topic, true

    it 'that is a two-digit year', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, ('' + currentTime.getFullYear())[0...2]
      assert.equal topic, true

    it 'that is a two-digit year in the past (i.e. 1990s)', ->
      currentTime = new Date()
      topic = $.payment.validateCardExpiry currentTime.getMonth() + 1, 99
      assert.equal topic, false

    it 'that has string numbers', ->
      currentTime = new Date()
      currentTime.setFullYear(currentTime.getFullYear() + 1, currentTime.getMonth() + 2)
      topic = $.payment.validateCardExpiry currentTime.getMonth() + '', currentTime.getFullYear() + ''
      assert.equal topic, true

    it 'that has non-numbers', ->
      topic = $.payment.validateCardExpiry 'h12', '3300'
      assert.equal topic, false

    it 'should fail if year or month is NaN', ->
      topic = $.payment.validateCardExpiry '12', NaN
      assert.equal topic, false

    it 'should fail if year is to far from now', ->
      topic = $.payment.validateCardExpiry('12', '2033')
      assert.equal topic, false

    it 'should support year shorthand', ->
      assert.equal $.payment.validateCardExpiry('05', '20'), true

  describe 'Validating a CVC number', ->
    it 'should validate a three digit number with no card type', ->
      topic = $.payment.validateCardCVC('123')
      assert.equal topic, true

    it 'should validate a three digit number with card type amex', ->
      topic = $.payment.validateCardCVC('123', 'amex')
      assert.equal topic, false

    it 'should validate a three digit number with card type other than amex', ->
      topic = $.payment.validateCardCVC('123', 'visa')
      assert.equal topic, true

    it 'should not validate a four digit number with a card type other than amex', ->
      topic = $.payment.validateCardCVC('1234', 'visa')
      assert.equal topic, false

    it 'should not validate a four digit number with card type amex', ->
      topic = $.payment.validateCardCVC('1234', 'amex')
      assert.equal topic, true

    it 'should not validate a number larger than 4 digits', ->
      topic = $.payment.validateCardCVC('12344')
      assert.equal topic, false

  describe 'Parsing an expiry value', ->
    it 'should parse string expiry', ->
      topic = $.payment.cardExpiryVal('03 / 2025')
      assert.deepEqual topic, month: 3, year: 2025

    it 'should support shorthand year', ->
      topic = $.payment.cardExpiryVal('05/04')
      assert.deepEqual topic, month: 5, year: 2004

    it 'should return NaN when it cannot parse', ->
      topic = $.payment.cardExpiryVal('05/dd')
      assert isNaN(topic.year)

  describe 'Getting a card type', ->
    it 'should return Visa that begins with 40', ->
      topic = $.payment.cardType '4012121212121212'
      assert.equal topic, 'visa'

    it 'that begins with 5 should return MasterCard', ->
      topic = $.payment.cardType '5555555555554444'
      assert.equal topic, 'master'

    it 'that begins with 34 should return American Express', ->
      topic = $.payment.cardType '3412121212121212'
      assert.equal topic, 'amex'

    it 'that is not numbers should return null', ->
      topic = $.payment.cardType 'aoeu'
      assert.equal topic, null

    it 'that has unrecognized beginning numbers should return null', ->
      topic = $.payment.cardType 'aoeu'
      assert.equal topic, null

    it 'should return correct type for all test numbers', ->
      assert($.payment.cardType('4029174173871700'), 'naranja')
      assert($.payment.cardType('4029188823230745'), 'naranja')
      assert($.payment.cardType('5275718605203862'), 'naranja')
      assert($.payment.cardType('5275720847313376'), 'naranja')
      assert($.payment.cardType('5895625366531656'), 'naranja')

      assert($.payment.cardType('5465531782847777'), 'nativa')

      assert($.payment.cardType('6034880724565165'), 'tarshop')
      assert($.payment.cardType('279957310758')    , 'tarshop')

      assert($.payment.cardType('6034937348103201'), 'cencosud')
      
      assert($.payment.cardType('6271702268025038'), 'cabal')
      assert($.payment.cardType('5896577655366865'), 'cabal')
      assert($.payment.cardType('6035221580711081'), 'cabal')
      assert($.payment.cardType('6042013013318555'), 'cabal')
      assert($.payment.cardType('6044002445876882'), 'cabal')

      assert($.payment.cardType('5011051045705026'), 'argencard')

      assert($.payment.cardType('4111111111111111'), 'visa')
      assert($.payment.cardType('4012888888881881'), 'visa')
      assert($.payment.cardType('4222222222222')   , 'visa')
      assert($.payment.cardType('4462030000000000'), 'visa')
      assert($.payment.cardType('4484070000000000'), 'visa')

      assert($.payment.cardType('5555555555554444'), 'master')
      assert($.payment.cardType('5454545454545454'), 'master')

      assert($.payment.cardType('378282246310005'), 'amex')
      assert($.payment.cardType('371449635398431'), 'amex')
      assert($.payment.cardType('378734493671000'), 'amex')

      assert($.payment.cardType('36700102000000'), 'diners')
      assert($.payment.cardType('36148900647913'), 'diners')

      assert($.payment.cardType('6062822241875177'), 'hipercard')

      assert($.payment.cardType('6363685624067423'), 'elo')
      assert($.payment.cardType('4389357440762745'), 'elo')
      assert($.payment.cardType('5067268104457611'), 'elo')
      assert($.payment.cardType('4576311327618218'), 'elo')

      assert($.payment.cardType('5300321316680145'), 'melicard')
      assert($.payment.cardType('5224991854532800'), 'melicard')

  describe 'formatCardNumber', ->
    it 'should format cc number correctly', (done) ->
      $number = $('<input type=text>').payment('formatCardNumber')
      $number.val('4242')

      e = $.Event('keypress');
      e.which = 52 # '4'
      $number.trigger(e)

      setTimeout ->
        assert.equal $number.val(), '4242 4'
        done()

    it 'should format amex cc number correctly', (done) ->
      $number = $('<input type=text>').payment('formatCardNumber')
      $number.val('3782')

      e = $.Event('keypress');
      e.which = 56 # '8'
      $number.trigger(e)

      setTimeout ->
        assert.equal $number.val(), '3782 8'
        done()

  describe 'formatCardExpiry', ->
    it 'should format month shorthand correctly', (done) ->
      $expiry = $('<input type=text>').payment('formatCardExpiry')

      e = $.Event('keypress');
      e.which = 52 # '4'
      $expiry.trigger(e)

      setTimeout ->
        assert.equal $expiry.val(), '04 / '
        done()

    it 'should format forward slash shorthand correctly', (done) ->
      $expiry = $('<input type=text>').payment('formatCardExpiry')
      $expiry.val('1')

      e = $.Event('keypress');
      e.which = 47 # '/'
      $expiry.trigger(e)

      setTimeout ->
        assert.equal $expiry.val(), '01 / '
        done()

    it 'should only allow numbers', (done) ->
      $expiry = $('<input type=text>').payment('formatCardExpiry')
      $expiry.val('1')

      e = $.Event('keypress');
      e.which = 100 # 'd'
      $expiry.trigger(e)

      setTimeout ->
        assert.equal $expiry.val(), '1'
        done()
	
	describe 'validateCPF', ->
		it 'sould not validate this numbers', (done) ->
			assert.equal $.payment.validateCPF('123'), false
			assert.equal $.payment.validateCPF('00000000000'), false
			assert.equal $.payment.validateCPF('11111111111'), false
			assert.equal $.payment.validateCPF('22222222222'), false
			assert.equal $.payment.validateCPF('33333333333'), false
			assert.equal $.payment.validateCPF('44444444444'), false
			assert.equal $.payment.validateCPF('55555555555'), false
			assert.equal $.payment.validateCPF('66666666666'), false
			assert.equal $.payment.validateCPF('77777777777'), false
			assert.equal $.payment.validateCPF('88888888888'), false
			assert.equal $.payment.validateCPF('99999999999'), false
			
			assert.equal $.payment.validateCPF('12810502370'), false
			assert.equal $.payment.validateCPF('12810202374'), false
			
			done()
		
		it 'sould not validate a cpf if lengh more than 11', (done) ->
			assert.equal $.payment.validateCPF('509128143650'), false
			done()

		it 'sould validate this numbers', (done) ->
			assert.equal $.payment.validateCPF('50912814365'), true
			assert.equal $.payment.validateCPF('49625494723'), true
			assert.equal $.payment.validateCPF('12810502374'), true
			done()
