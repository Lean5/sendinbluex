defmodule SendInBlue.Entity do
  @moduledoc """
  A module that provides a __using__ macro to create the typespec,
  the defstruct and a typedesc() function to parse JSON data.

  Intended for internal use within the library.
  """

  defmacro __using__(spec) do
    fields = spec |> Enum.map(&elem(&1, 0))
    type_spec = {:%, [], [{:__MODULE__, [], __CALLER__.module}, {:%{}, [], spec}]}
    desc = build_type_description(spec)

    quote do
      @type t :: unquote(type_spec)
      
      defstruct unquote(fields)

      def typedesc() do
        unquote(desc)
      end
    end
  end

  defp build_type_description(spec) do
    spec = Enum.map(spec, fn {f, t} -> {f, type_desc(t)} end)
    {:%{}, [], spec}
  end

  defp type_desc({{:., _, [{:__aliases__, _, module}, :t]}, _, []}) do
    module = Module.concat(["Elixir" | module])
    if Code.ensure_compiled?(module) and :erlang.function_exported(module, :typedesc, 0) do
      quote do
        unquote(module).typedesc()
      end
    else
      nil
    end
  end

  defp type_desc({:list, _, [type]}) do
    quote do
      [ unquote(type_desc(type)) ]
    end
  end

  defp type_desc(_), do: nil
end