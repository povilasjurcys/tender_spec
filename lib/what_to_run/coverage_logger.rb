require 'redis'
require_relative 'dir_locatable'

module WhatToRun
  class CoverageLogger
    REDIS = Redis.new

    include DirLocatable

    def key_namespace
      "what_to_run/coverage/#{shared_commit_key}"
    end

    def log(description, coverage)
      coverage.each_pair do |file_name, file_coverage|
        file_coverage.each.with_index do |is_covered, line_index|
          next unless is_covered == 1
          REDIS.sadd("#{key_namespace}::#{file_name}:#{line_index + 1}", description)
        end
      end
    end

    def clear_unfinished
      good_prefixes = REDIS.keys('what_to_run/coverage/*/finished').map do |key|
        key[0, key.length - '/finished'.length]
      end

      invalid_keys = REDIS.keys('what_to_run/coverage/*').reject do |key|
        good_prefixes.any? { |prefix| key.starts_with?(prefix) }
      end

      REDIS.del(invalid_keys)
    end

    def covered_lines
      prefix = "#{key_namespace}::"
      REDIS.keys("#{prefix}*").map do |key|
        key[prefix.length, key.length]
      end
    end

    def get_descriptions(file_line)
      REDIS.smembers("#{key_namespace}::#{file_line}") || []
    end

    def finish
      REDIS.setex(finished_key, 'true', 7.days.to_i)
    end

    def finished?
      REDIS.get(finished_key).to_s == 'true'
    end

    def reset
      REDIS.del(finished_key)
    end

    private

    def finished_key
      "#{key_namespace}/finished"
    end

  end
end
