class SampleTemplate < Quirkey::Porterable::Template
  set_map 'id', 
          'first_name', 
          'last_name', 
          ['billing_address_address_1','billing_address.address1'], 
          ['billing_address_postal', proc { billing_address.postal }]
end