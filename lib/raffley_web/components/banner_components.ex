defmodule RaffleyWeb.BannerComponents do
  use Phoenix.Component

  slot :inner_block, required: true
  slot :details

  def banner(assigns) do
    assigns = assign_new(assigns, :emoji, fn -> ~w(😎 🤩 🥳) |> Enum.random() end)

    ~H"""
    <div class="banner">
      <h1>
        {render_slot(@inner_block)}
      </h1>
      <div :for={details <- @details} class="details">
        {render_slot(details, @emoji)}
      </div>
    </div>
    """
  end
end
