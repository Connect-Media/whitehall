module Admin::SidebarHelper
  def simple_formatting_sidebar
    sidebar_tabs govspeak_help: "Formatting Help" do
      content_tag :section, class: "tab-pane active", id: "govspeak_help" do
        render partial: "admin/editions/govspeak_help"
      end
    end
  end

  def edition_tabs(edition, editing=false)
    if editing
      tabs = {govspeak_help: "Formatting Help"}
    else
      tabs = {assocations: "Associations"}
    end
    tabs[:history] = ["History & Notes", @edition.audit_trail.length]
    if @edition.can_be_fact_checked?
      tabs[:fact_checking] = ["Fact checking", @edition.fact_check_requests.pending.count, :warning]
    end
    tabs
  end

  def sidebar_tabs(tabs, &block)
    tab_tags = tabs.map.with_index do |(id, tab_content), index|
      link_content = case tab_content
      when String
        tab_content
      when Array
        text = tab_content[0]
        badge_content = tab_content[1]
        badge_type = tab_content[2]
        if badge_content
          badge_class = badge_type ? "badge badge-#{badge_type}" : "badge"
          text.html_safe + " " + content_tag(:span, badge_content, class: badge_class)
        else
          text
        end
      end
      link = content_tag(:a, link_content, "href" => "##{id}", "data-toggle" => "tab")
      content_tag(:li, link, class: (index == 0 ? "active" : nil))
    end
    content_tag(:div, class: "sidebar tabbable") do
      content_tag(:ul, class: "nav nav-tabs") do
        tab_tags.join.html_safe
      end +
      content_tag(:div, class: "tab-content") do
        yield
      end
    end
  end
end