defmodule SendInBlue.Utils do
  @moduledoc false

  def camelize_keys(m) do
    Enum.into(m, %{}, fn {k, v} -> {camelize(k), v} end)
  end

  def camelize(v) when is_atom(v), do: camelize(Atom.to_string(v))
  def camelize(word) when is_binary(word) do
    {first, rest} = String.split_at(Macro.camelize(word), 1)
    String.downcase(first) <> rest
  end
end
