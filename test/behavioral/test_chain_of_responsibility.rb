# frozen_string_literal: true

require_relative '../test_helper'
require_relative '../../lib/behavioral/chain_of_responsibility/chain_of_responsibility'

class TestChainOfResponsibility < GofPatternTest
  def test_request_creation
    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :authenticate,
      content: 'token123',
      metadata: { ip: '127.0.0.1' }
    )

    assert_equal :authenticate, request.type
    assert_equal 'token123', request.content
    assert_predicate request, :frozen?
  end

  def test_response_success
    response = GofPatterns::Behavioral::ChainOfResponsibility::Response.new(
      success: true,
      message: 'OK',
      handler: 'TestHandler',
      data: { key: 'value' }
    )

    assert_predicate response, :success?
    assert_equal 'OK', response.message
  end

  def test_authentication_handler_valid_token
    handler = GofPatterns::Behavioral::ChainOfResponsibility::AuthenticationHandler.new(
      valid_tokens: %w[token1 token2]
    )
    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :authenticate,
      content: 'token1'
    )

    response = handler.handle(request)

    assert_predicate response, :success?
    assert_match(/Authentication successful/, response.message)
  end

  def test_authentication_handler_invalid_token
    handler = GofPatterns::Behavioral::ChainOfResponsibility::AuthenticationHandler.new(
      valid_tokens: %w[token1 token2]
    )
    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :authenticate,
      content: 'invalid_token'
    )

    response = handler.handle(request)

    refute_predicate response, :success?
    assert_match(/Invalid token/, response.message)
  end

  def test_authorization_handler
    handler = GofPatterns::Behavioral::ChainOfResponsibility::AuthorizationHandler.new(
      permissions: { admin: %i[read write delete], user: %i[read] }
    )
    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :authorize,
      content: :write,
      metadata: { role: :admin }
    )

    response = handler.handle(request)

    assert_predicate response, :success?
  end

  def test_authorization_handler_denied
    handler = GofPatterns::Behavioral::ChainOfResponsibility::AuthorizationHandler.new(
      permissions: { admin: %i[read write delete], user: %i[read] }
    )
    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :authorize,
      content: :delete,
      metadata: { role: :user }
    )

    response = handler.handle(request)

    refute_predicate response, :success?
  end

  def test_validation_handler
    validators = [
      ->(data) { data[:name].nil? ? 'Name is required' : nil },
      ->(data) { data[:age].to_i.negative? ? 'Age must be positive' : nil }
    ]
    handler = GofPatterns::Behavioral::ChainOfResponsibility::ValidationHandler.new(
      validators: validators
    )
    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :validate,
      content: { name: 'John', age: 25 }
    )

    response = handler.handle(request)

    assert_predicate response, :success?
  end

  def test_validation_handler_fails
    validators = [
      ->(data) { data[:name].nil? ? 'Name is required' : nil }
    ]
    handler = GofPatterns::Behavioral::ChainOfResponsibility::ValidationHandler.new(
      validators: validators
    )
    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :validate,
      content: { age: 25 }
    )

    response = handler.handle(request)

    refute_predicate response, :success?
  end

  def test_handler_chain
    auth = GofPatterns::Behavioral::ChainOfResponsibility::AuthenticationHandler.new(
      valid_tokens: ['secret']
    )
    authz = GofPatterns::Behavioral::ChainOfResponsibility::AuthorizationHandler.new(
      permissions: { admin: [:read] }
    )
    default = GofPatterns::Behavioral::ChainOfResponsibility::DefaultHandler.new

    auth.set_next(authz).set_next(default)

    # Auth request goes to auth handler
    auth_request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :authenticate,
      content: 'secret'
    )

    assert_predicate auth.handle(auth_request), :success?

    # Unknown request goes to default handler
    unknown = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :unknown,
      content: 'test'
    )
    response = auth.handle(unknown)

    assert_predicate response, :success?
    assert_match(/default handler/, response.message)
  end

  def test_logging_handler_passes_through
    logs = []
    logger = ->(msg) { logs << msg }
    logging = GofPatterns::Behavioral::ChainOfResponsibility::LoggingHandler.new(logger: logger)
    default = GofPatterns::Behavioral::ChainOfResponsibility::DefaultHandler.new

    logging.set_next(default)

    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :test,
      content: 'test content'
    )

    response = logging.handle(request)

    assert_predicate response, :success?
    refute_empty logs
  end

  def test_support_ticket_creation
    ticket = GofPatterns::Behavioral::ChainOfResponsibility::SupportTicket.new(
      id: 'T-001',
      priority: :high,
      type: :technical,
      description: 'Issue'
    )

    assert_equal 'T-001', ticket.id
    assert_equal :high, ticket.priority
    refute_predicate ticket, :critical?
  end

  def test_support_ticket_invalid_priority
    assert_raises(ArgumentError) do
      GofPatterns::Behavioral::ChainOfResponsibility::SupportTicket.new(
        id: 'T-001',
        priority: :invalid,
        type: :general,
        description: 'Test'
      )
    end
  end

  def test_support_chain
    chain = GofPatterns::Behavioral::ChainOfResponsibility::SupportChainBuilder.build

    # General low priority -> Level 1
    general_ticket = GofPatterns::Behavioral::ChainOfResponsibility::SupportTicket.new(
      id: 'T-001',
      priority: :low,
      type: :general,
      description: 'General question'
    )
    response = chain.handle(general_ticket)

    assert_predicate response, :success?
    assert_match(/Level 1/, response.handler)

    # Technical medium -> Level 2
    tech_ticket = GofPatterns::Behavioral::ChainOfResponsibility::SupportTicket.new(
      id: 'T-002',
      priority: :medium,
      type: :technical,
      description: 'Tech issue'
    )
    response = chain.handle(tech_ticket)

    assert_predicate response, :success?
    assert_match(/Level 2/, response.handler)

    # Critical -> Level 3
    critical_ticket = GofPatterns::Behavioral::ChainOfResponsibility::SupportTicket.new(
      id: 'T-003',
      priority: :critical,
      type: :technical,
      description: 'Critical issue'
    )
    response = chain.handle(critical_ticket)

    assert_predicate response, :success?
    assert_match(/Level 3/, response.handler)
  end

  def test_request_chain_builder
    builder = GofPatterns::Behavioral::ChainOfResponsibility::RequestChainBuilder.new
    chain = builder
            .add(GofPatterns::Behavioral::ChainOfResponsibility::LoggingHandler.new(logger: ->(_) {}))
            .add(GofPatterns::Behavioral::ChainOfResponsibility::DefaultHandler.new)
            .build

    request = GofPatterns::Behavioral::ChainOfResponsibility::Request.new(
      type: :test,
      content: 'test'
    )

    response = chain.handle(request)

    assert_predicate response, :success?
  end
end
