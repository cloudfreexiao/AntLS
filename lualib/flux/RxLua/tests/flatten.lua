describe('flatten', function()
  it('produces an error if its parent errors', function()
    local observable = Rx.Observable.of(''):map(function(x) return x() end)
    expect(observable).to.produce.error()
    expect(observable:flatten()).to.produce.error()
  end)

  it('produces all values produced by the observables produced by its parent', function()
    local observable = Rx.Observable.fromRange(3):map(function(i)
      return Rx.Observable.fromRange(i, 3)
    end):flatten()

    expect(observable).to.produce(1, 2, 3, 2, 3, 3)
  end)

  it('should unsubscribe from all source observables', function()
    local unsubscribeA = spy()
    local observableA = Rx.Observable.create(function(observer)
      return Rx.Subscription.create(unsubscribeA)
    end)

    local unsubscribeB = spy()
    local observableB = Rx.Observable.create(function(observer)
      return Rx.Subscription.create(unsubscribeB)
    end)

    local subject = Rx.Subject.create()
    local subscription = subject:flatten():subscribe()

    subject:onNext(observableA)
    subject:onNext(observableB)
    subscription:unsubscribe()
    expect(#unsubscribeA).to.equal(1)
    expect(#unsubscribeB).to.equal(1)
  end)
end)