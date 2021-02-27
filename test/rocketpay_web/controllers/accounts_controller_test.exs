defmodule RocketpayWeb.AccountsControllerTest do
  use RocketpayWeb.ConnCase, async: true

  alias Rocketpay.{Account, User}

  describe "deposit/2" do
    setup %{conn: conn} do
      user_params = %{
        name: "Jefferson",
        password: "123456",
        nickname: "Farias",
        email: "jefferson-testador@teste.com",
        age: 29
      }

      {:ok, %User{account: %Account{id: account_id}}} = Rocketpay.create_user(user_params)

      conn = put_req_header(conn, "authorization", "Basic YmFuYW5hOm5hbmljYTEyMw==")

      {:ok, conn: conn, account_id: account_id}
    end

    test "when all params are valid, make the deposit", %{conn: conn, account_id: account_id} do
      params = %{value: 10.0}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id), params)
        |> json_response(:ok)

      assert %{
               "account" => %{"balance" => "10.00", "id" => _id},
               "message" => "Balance changed successfully"
             } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn, account_id: account_id} do
      params = %{value: -10.0}

      response =
        conn
        |> post(Routes.accounts_path(conn, :deposit, account_id), params)
        |> json_response(:bad_request)

      expected_response = %{"message" => %{"balance" => ["is invalid"]}}

      assert expected_response == response
    end
  end
end
