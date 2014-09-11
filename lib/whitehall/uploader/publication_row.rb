module Whitehall::Uploader
  class PublicationRow < Row
    include UploaderHelpers

    def self.validator
      super
        .multiple("policy_#", 0..20)
        .multiple("document_collection_#", 0..4)
        .required(%w{publication_type publication_date})
        .optional(%w{order_url price isbn urn command_paper_number}) # First attachment
        .optional(%w{hoc_paper_number parliamentary_session unnumbered_hoc_paper unnumbered_command_paper}) # First attachment
        .ignored("ignore_*")
        .multiple(%w{attachment_#_url attachment_#_title}, 0..Row::ATTACHMENT_LIMIT)
        .optional('json_attachments')
        .multiple("country_#", 0..4)
        .optional(%w(html_title html_body))
        .multiple('html_body_#', 0..99)
        .multiple("topic_#", 0..4)
    end

    def first_published_at
      Parsers::DateParser.parse(row['publication_date'], @logger, @line_number)
    end

    def publication_type
      Finders::PublicationTypeFinder.find(row['publication_type'], @logger, @line_number)
    end

    def related_editions
      Finders::EditionFinder.new(Policy, @logger, @line_number).find(*policy_slugs)
    end

    def document_collections
      fields(1..4, 'document_collection_#').compact.reject(&:blank?)
    end

    def ministerial_roles
      Finders::MinisterialRolesFinder.find(first_published_at, row['minister_1'], row['minister_2'], @logger, @line_number)
    end

    def attachments
      if @attachments.nil?
        @attachments = attachments_from_columns + attachments_from_json
        apply_meta_data_to_attachment(@attachments.first) if @attachments.any?
      end
      @attachments
    end

    def alternative_format_provider
      organisations.first
    end

    def html_title
      row['html_title']
    end

    def html_body
      if row['html_body']
        ([row['html_body']] + (1..99).map {|n| row["html_body_#{n}"] }).compact.join
      end
    end

    def html_attachment_attributes
      { title: html_title, body: html_body }
    end

  protected
    def attribute_keys
      super + [
        :alternative_format_provider,
        :attachments,
        :first_published_at,
        :html_attachment_attributes,
        :lead_organisations,
        :ministerial_roles,
        :publication_type,
        :related_editions,
        :topics,
        :world_locations
      ]
    end

  private

    def policy_slugs
      row.to_hash.select {|k, v| k =~ /^policy_\d+$/ }.values
    end

    def apply_meta_data_to_attachment(attachment)
      attachment.order_url = row["order_url"]
      attachment.isbn = row["isbn"]
      attachment.unique_reference = row["urn"]
      attachment.command_paper_number = row["command_paper_number"]
      attachment.price = row["price"]
      attachment.hoc_paper_number = row["hoc_paper_number"]
      attachment.parliamentary_session = row["parliamentary_session"]
      attachment.unnumbered_hoc_paper = row["unnumbered_hoc_paper"]
      attachment.unnumbered_command_paper = row["unnumbered_command_paper"]
    end
  end
end
