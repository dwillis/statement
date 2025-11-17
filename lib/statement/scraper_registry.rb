module Statement
  class ScraperRegistry
    class << self
      attr_reader :scrapers

      def initialize_registry
        @scrapers = {
          members: {},
          committees: {}
        }
      end

      # Register a member scraper
      def register_member(name, klass, method_name, metadata = {})
        @scrapers ||= initialize_registry
        @scrapers[:members][name] = {
          class: klass,
          method: method_name,
          chamber: metadata[:chamber] || :unknown,
          party: metadata[:party],
          state: metadata[:state],
          district: metadata[:district],
          pattern: metadata[:pattern]
        }
      end

      # Register a committee scraper
      def register_committee(name, klass, method_name, metadata = {})
        @scrapers ||= initialize_registry
        @scrapers[:committees][name] = {
          class: klass,
          method: method_name,
          chamber: metadata[:chamber] || :unknown,
          party: metadata[:party],
          committee: metadata[:committee]
        }
      end

      # Get all member scrapers
      def member_scrapers
        @scrapers ||= initialize_registry
        @scrapers[:members]
      end

      # Get all committee scrapers
      def committee_scrapers
        @scrapers ||= initialize_registry
        @scrapers[:committees]
      end

      # Get scrapers by chamber (house, senate, or both)
      def scrapers_by_chamber(chamber, type: :members)
        @scrapers ||= initialize_registry
        return [] unless [:members, :committees].include?(type)

        @scrapers[type].select do |name, meta|
          meta[:chamber] == chamber.to_sym
        end
      end

      # Execute a scraper by name
      def execute(type, name, *args)
        @scrapers ||= initialize_registry
        scraper_info = @scrapers[type][name]
        return nil unless scraper_info

        klass = scraper_info[:class]
        method = scraper_info[:method]
        klass.send(method, *args)
      end

      # Get all available scraper names
      def all_scraper_names(type = nil)
        @scrapers ||= initialize_registry
        if type
          @scrapers[type].keys
        else
          @scrapers[:members].keys + @scrapers[:committees].keys
        end
      end
    end
  end
end
