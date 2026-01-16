# frozen_string_literal: true

module GofPatterns
  module Behavioral
    # Chain of Responsibility Pattern (責任の連鎖パターン)
    # ================================================
    # 目的: リクエストを処理できるオブジェクトのチェーンに沿って渡し、
    #       適切なハンドラに処理させる
    #
    # DDD Context:
    # - Domain Service のパイプライン処理
    # - バリデーションチェーン

    module ChainOfResponsibility
      # Value Object: リクエスト
      class Request
        attr_reader :type, :content, :metadata

        def initialize(type:, content:, metadata: {})
          @type = type.to_sym
          @content = content.freeze
          @metadata = metadata.freeze
          freeze
        end

        def ==(other)
          return false unless other.is_a?(Request)

          type == other.type && content == other.content
        end
        alias eql? ==

        def hash
          [type, content].hash
        end
      end

      # Value Object: レスポンス
      class Response
        attr_reader :success, :message, :handler, :data

        def initialize(success:, message:, handler: nil, data: nil)
          @success = success
          @message = message.freeze
          @handler = handler
          @data = data
          freeze
        end

        def success?
          success
        end

        def ==(other)
          return false unless other.is_a?(Response)

          success == other.success && message == other.message
        end
        alias eql? ==

        def hash
          [success, message].hash
        end
      end

      # Handler Interface: ハンドラ基底クラス
      class Handler
        attr_accessor :next_handler

        def set_next(handler)
          @next_handler = handler
          handler
        end

        def handle(request)
          if can_handle?(request)
            process(request)
          elsif @next_handler
            @next_handler.handle(request)
          else
            Response.new(
              success: false,
              message: "No handler found for request type: #{request.type}"
            )
          end
        end

        protected

        def can_handle?(_request)
          raise NotImplementedError
        end

        def process(_request)
          raise NotImplementedError
        end
      end

      # Concrete Handler: 認証ハンドラ
      class AuthenticationHandler < Handler
        def initialize(valid_tokens: [])
          @valid_tokens = valid_tokens
        end

        protected

        def can_handle?(request)
          request.type == :authenticate
        end

        def process(request)
          token = request.content
          if @valid_tokens.include?(token)
            Response.new(
              success: true,
              message: 'Authentication successful',
              handler: self.class.name,
              data: { token: token, authenticated: true }
            )
          else
            Response.new(
              success: false,
              message: 'Invalid token',
              handler: self.class.name
            )
          end
        end
      end

      # Concrete Handler: 認可ハンドラ
      class AuthorizationHandler < Handler
        def initialize(permissions: {})
          @permissions = permissions
        end

        protected

        def can_handle?(request)
          request.type == :authorize
        end

        def process(request)
          user_role = request.metadata[:role]
          action = request.content

          allowed = @permissions[user_role]&.include?(action)
          if allowed
            Response.new(
              success: true,
              message: "Action '#{action}' authorized for role '#{user_role}'",
              handler: self.class.name,
              data: { authorized: true }
            )
          else
            Response.new(
              success: false,
              message: "Action '#{action}' not authorized for role '#{user_role}'",
              handler: self.class.name
            )
          end
        end
      end

      # Concrete Handler: バリデーションハンドラ
      class ValidationHandler < Handler
        def initialize(validators: [])
          @validators = validators
        end

        protected

        def can_handle?(request)
          request.type == :validate
        end

        def process(request)
          data = request.content
          errors = []

          @validators.each do |validator|
            result = validator.call(data)
            errors << result unless result.nil?
          end

          if errors.empty?
            Response.new(
              success: true,
              message: 'Validation passed',
              handler: self.class.name,
              data: { valid: true }
            )
          else
            Response.new(
              success: false,
              message: "Validation failed: #{errors.join(', ')}",
              handler: self.class.name,
              data: { errors: errors }
            )
          end
        end
      end

      # Concrete Handler: ロギングハンドラ（全てのリクエストを処理してから次へ）
      class LoggingHandler < Handler
        def initialize(logger: nil)
          @logger = logger || ->(msg) { puts "[LOG] #{msg}" }
          @logs = []
        end

        attr_reader :logs

        def handle(request)
          log_message = "Request: type=#{request.type}, content=#{request.content}"
          @logger.call(log_message)
          @logs << log_message

          # ログ記録後、次のハンドラに渡す
          if @next_handler
            @next_handler.handle(request)
          else
            Response.new(
              success: true,
              message: 'Request logged',
              handler: self.class.name
            )
          end
        end

        protected

        def can_handle?(_request)
          true
        end

        def process(_request)
          Response.new(
            success: true,
            message: 'Logged',
            handler: self.class.name
          )
        end
      end

      # Concrete Handler: デフォルトハンドラ
      class DefaultHandler < Handler
        protected

        def can_handle?(_request)
          true
        end

        def process(request)
          Response.new(
            success: true,
            message: "Request of type '#{request.type}' handled by default handler",
            handler: self.class.name,
            data: { content: request.content }
          )
        end
      end

      # ===== サポートチケット例 =====

      # Value Object: サポートチケット
      class SupportTicket
        attr_reader :id, :priority, :type, :description

        PRIORITIES = %i[low medium high critical].freeze
        TYPES = %i[technical billing general feedback].freeze

        def initialize(id:, priority:, type:, description:)
          raise ArgumentError, "Invalid priority: #{priority}" unless PRIORITIES.include?(priority)
          raise ArgumentError, "Invalid type: #{type}" unless TYPES.include?(type)

          @id = id.freeze
          @priority = priority
          @type = type
          @description = description.freeze
          freeze
        end

        def critical?
          priority == :critical
        end

        def ==(other)
          return false unless other.is_a?(SupportTicket)

          id == other.id
        end
        alias eql? ==

        def hash
          id.hash
        end
      end

      # Support Handler Base
      class SupportHandler < Handler
        attr_reader :handled_tickets

        def initialize(name)
          @name = name
          @handled_tickets = []
        end

        def handle(ticket)
          if can_handle_ticket?(ticket)
            @handled_tickets << ticket
            process_ticket(ticket)
          elsif @next_handler
            @next_handler.handle(ticket)
          else
            Response.new(
              success: false,
              message: "No support available for ticket #{ticket.id}"
            )
          end
        end

        protected

        def can_handle_ticket?(_ticket)
          raise NotImplementedError
        end

        def process_ticket(_ticket)
          raise NotImplementedError
        end

        def can_handle?(_request)
          false
        end

        def process(_request)
          nil
        end
      end

      # Level 1 Support
      class Level1Support < SupportHandler
        def initialize
          super('Level 1 Support')
        end

        protected

        def can_handle_ticket?(ticket)
          %i[general feedback].include?(ticket.type) && %i[low medium].include?(ticket.priority)
        end

        def process_ticket(ticket)
          Response.new(
            success: true,
            message: "Ticket #{ticket.id} handled by #{@name}",
            handler: @name,
            data: { resolution: 'Basic support provided' }
          )
        end
      end

      # Level 2 Support
      class Level2Support < SupportHandler
        def initialize
          super('Level 2 Support')
        end

        protected

        def can_handle_ticket?(ticket)
          ticket.type == :technical && %i[low medium high].include?(ticket.priority)
        end

        def process_ticket(ticket)
          Response.new(
            success: true,
            message: "Ticket #{ticket.id} handled by #{@name}",
            handler: @name,
            data: { resolution: 'Technical support provided' }
          )
        end
      end

      # Level 3 Support (Management)
      class Level3Support < SupportHandler
        def initialize
          super('Level 3 Support (Management)')
        end

        protected

        def can_handle_ticket?(ticket)
          ticket.critical? || ticket.type == :billing
        end

        def process_ticket(ticket)
          Response.new(
            success: true,
            message: "Ticket #{ticket.id} escalated to #{@name}",
            handler: @name,
            data: { resolution: 'Management intervention required' }
          )
        end
      end

      # Domain Service: サポートチェーンビルダー
      class SupportChainBuilder
        def self.build
          level1 = Level1Support.new
          level2 = Level2Support.new
          level3 = Level3Support.new

          level1.set_next(level2).set_next(level3)
          level1
        end
      end

      # Domain Service: リクエストハンドラチェーンビルダー
      class RequestChainBuilder
        def initialize
          @handlers = []
        end

        def add(handler)
          @handlers << handler
          self
        end

        def build
          return nil if @handlers.empty?

          @handlers.each_cons(2) do |current, next_handler|
            current.set_next(next_handler)
          end
          @handlers.first
        end
      end
    end
  end
end
