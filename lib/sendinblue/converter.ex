defmodule SendInBlue.Converter do

  def convert(value, nil), do: value
  def convert(nil, _type), do: nil

  def convert(value, [type]) when is_list(value),
    do: value |> Enum.map(&convert(&1, type))

  def convert(value, type) when is_list(value),
    do: raise "Cannot convert #{inspect value} to type #{inspect type}"

  def convert(value, module) when is_map(value) and is_atom(module) do
    Code.ensure_loaded(module)
    if not :erlang.function_exported(module, :typedesc, 0) do
      raise "Cannnot convert #{inspect value} to type #{inspect module} because the module does not export a typedesc function."
    end
    struct(module, convert(value, module.typedesc()))
  end

  def convert(value, %{} = type) when is_map(value) do
    type
    |> Enum.reduce(%{},
      fn {key, type}, acc ->
        string_key = SendInBlue.Utils.camelize(key)
        v = Map.get(value, string_key) |> convert(type)
        Map.put(acc, key, v)
      end)
  end
end