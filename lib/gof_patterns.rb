# frozen_string_literal: true

# GoF Design Patterns in Ruby
# ===========================
# Ruby 3.4.8での Gang of Four デザインパターン実装
# DDD (Domain-Driven Design) アプローチを採用

module GofPatterns
  VERSION = '1.0.0'

  # Creational Patterns (生成パターン)
  module Creational
    autoload :Singleton, 'creational/singleton/singleton'
    autoload :FactoryMethod, 'creational/factory_method/factory_method'
    autoload :AbstractFactory, 'creational/abstract_factory/abstract_factory'
    autoload :Builder, 'creational/builder/builder'
    autoload :Prototype, 'creational/prototype/prototype'
  end

  # Structural Patterns (構造パターン)
  module Structural
    autoload :Adapter, 'structural/adapter/adapter'
    autoload :Bridge, 'structural/bridge/bridge'
    autoload :Composite, 'structural/composite/composite'
    autoload :Decorator, 'structural/decorator/decorator'
    autoload :Facade, 'structural/facade/facade'
    autoload :Flyweight, 'structural/flyweight/flyweight'
    autoload :Proxy, 'structural/proxy/proxy'
  end

  # Behavioral Patterns (振る舞いパターン)
  module Behavioral
    autoload :ChainOfResponsibility, 'behavioral/chain_of_responsibility/chain_of_responsibility'
    autoload :Command, 'behavioral/command/command'
    autoload :Interpreter, 'behavioral/interpreter/interpreter'
    autoload :Iterator, 'behavioral/iterator/iterator'
    autoload :Mediator, 'behavioral/mediator/mediator'
    autoload :Memento, 'behavioral/memento/memento'
    autoload :Observer, 'behavioral/observer/observer'
    autoload :State, 'behavioral/state/state'
    autoload :Strategy, 'behavioral/strategy/strategy'
    autoload :TemplateMethod, 'behavioral/template_method/template_method'
    autoload :Visitor, 'behavioral/visitor/visitor'
  end
end
