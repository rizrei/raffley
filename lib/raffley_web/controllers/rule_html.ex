defmodule RaffleyWeb.RuleHTML do
  use RaffleyWeb, :html

  embed_templates "rule_html/*"

  def show(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="rules">
        <h1>{@greating} Don't forget...</h1>
        <p>
          {@rule.text}
        </p>
      </div>
    </Layouts.app>
    """
  end
end
