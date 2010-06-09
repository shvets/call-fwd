module CallFwdHelper
  def call_forwarding_seconds_as_text index
    if index == 1
      "Instantly"
    else
      "#{index} Seconds"
    end
  end
end