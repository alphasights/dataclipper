defmodule Dataclipper do
  @sso_session "YOUR_SSO_SESSION_TOKEN"
  @csrf_session "YOUR_CSRF_SESSION_TOKEN"
  @from "resourcexxxxxxxx@heroku.com"
  @to "resourceyyyyyyyy@heroku.com"

  def run do
    cookie = "dataclips-sso-session=#{@sso_session}"

    response = HTTPotion.get("https://dataclips.heroku.com/api/v1/clips", headers: headers).body
    |> Poison.decode!
    |> Enum.filter(&Map.fetch!(&1, "heroku_resource_name") == "pistachio-analysis :: thinking-purposefully-5066")

    update(response)
  end

  def update([]) do
  end

  def update([head | tail]) do
    url = "https://dataclips.heroku.com/api/v1/clips/#{head["slug"]}/move"

    Task.async(fn ->
      Apex.ap HTTPotion.post(url, timeout: 45000, headers: headers, body: ~w({"heroku_resource_id":"#{@to}"}))
    end)
    :timer.sleep(500)
    update(tail)
  end

  defp headers do
    ["Cookie": "dataclips-sso-session=#{@sso_session}",
    "X-CSRF-Token": "#{@csrf_token}"]
  end
end
