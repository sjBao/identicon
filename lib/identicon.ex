defmodule Identicon do
  def main(input) do
    input 
    |> hash_input 
    |> pick_color 
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({top_right, bottom_left}) ->
      image |> :egd.filledRectangle(top_right, bottom_left, fill)
    end

    :egd.render(image)
  end

  def build_grid(%Identicon.Image{hex: hex} = image) do
    grid =
      hex 
      |> Enum.chunk_every(3, 3, :discard) 
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    
    %Identicon.Image{image | grid: grid}
  end

  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({ code, _index}) ->
      rem(code, 2) === 0
    end

    %Identicon.Image{image | grid: grid}
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({ _hex, index}) ->
        { x1, y1 } = { rem(index, 5) * 50, div(index, 5) * 50}
        { x2, y2 } = { x1 + 50, y1 + 50 }
        { {x1, y1}, {x2, y2} }
    end

    %Identicon.Image{image | pixel_map: pixel_map }
  end

  def mirror_row([one, two | _tail] = row) do
    row ++ [two, one]
  end

  def pick_color(%Identicon.Image{hex: [r,g,b | _tail]} = image) do
    %Identicon.Image{ image | color: {r, g, b} }
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input) |> :binary.bin_to_list
    %Identicon.Image{hex: hex}
  end
end
