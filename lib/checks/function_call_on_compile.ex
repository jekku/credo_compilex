defmodule CredoCompilex.Checks.FunctionCallOnCompile do
  use Credo.Check

  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(source_file, &traverse(&1, &2, issue_meta))
  end

  defp traverse({:@, _, [{attribute_name, meta, attribute_value}]} = ast, issues, issue_meta) do
    if function_call?(attribute_value) do
      {ast, issues ++ [issue_for(attribute_name, meta[:line], issue_meta)]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  defp function_call?([
         {{:., _,
           [
             _module,
             _function
           ]}, _, _}
       ]),
       do: true

  defp function_call?(_), do: false

  defp issue_for(trigger, line_no, issue_meta) do
    format_issue(
      issue_meta,
      message: "There should be no module attributes that are assigned functions.",
      trigger: "@#{trigger}",
      line_no: line_no
    )
  end
end
